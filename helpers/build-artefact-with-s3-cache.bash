#!/bin/bash

# NOTE: this snippet is used via templating, everything below
# works exactly as if written directly in a `shell` task!

USE_S3_CACHE=$(test '{{use_s3_build_cache | from_yaml}}' = 'True' && echo 1)
FORCE_REBUILD=$(test '{{force_rebuild | from_yaml}}' = 'True' && echo 1)
S3_CACHE_ENDPOINT='{{s3_cache_endpoint}}'
S3_CACHE_BUCKET='{{s3_cache_bucket}}'
export AWS_ACCESS_KEY_ID='{{s3_cache_access_key}}'
export AWS_SECRET_ACCESS_KEY='{{s3_cache_secret_key}}'
AWSCLI="aws --endpoint ${S3_CACHE_ENDPOINT} $(test -z $AWS_ACCESS_KEY_ID && echo '--no-sign-request')"

if [ -z $ARTEFACT_PATH ] ; then
  echo "ERROR: \$ARTEFACT_PATH is empty!"
  exit 1
fi

if [ -z $ARTEFACT_DIGEST ] ; then
  echo "ERROR: \$ARTEFACT_DIGEST is empty!"
  exit 1
fi

ARTEFACT_FILENAME="${ARTEFACT_S3_CACHE_FILE_NAME}_${ARTEFACT_DIGEST}"
ARTEFACT_S3_URL="s3://${S3_CACHE_BUCKET}/${ARTEFACT_FILENAME}"

function upload_to_cache {
  $AWSCLI --quiet --only-show-errors --no-progress \
    s3 cp "$ARTEFACT_PATH" "$ARTEFACT_S3_URL"
}
function check_is_in_cache {
  $AWSCLI s3 ls "$ARTEFACT_S3_URL"
}
function download_from_cache {
  $AWSCLI --quiet --only-show-errors --no-progress \
    s3 cp "$ARTEFACT_S3_URL" "$ARTEFACT_PATH"
}


cd "$PROJECT_DIR"
rm -rf "$ARTEFACT_PATH"

if [ ! $FORCE_REBUILD ] && download_from_cache; then
  echo "INFO: Rerrieved artefact from s3 cache ${ARTEFACT_S3_URL} @ ${S3_CACHE_ENDPOINT}"
  if declare -F restore_artefact >/dev/null; then
    if restore_artefact; then
      echo "INFO: Restored artefact from file ${ARTEFACT_PATH}"
    else
      echo "ERROR: Could not restore artefact from file ${ARTEFACT_PATH}"
      exit 1
    fi
  fi
else
  echo "INFO: No S3 cached artefact found ${ARTEFACT_S3_URL} @ ${S3_CACHE_ENDPOINT}"
fi

if [ $FORCE_REBUILD ] || [ ! $USE_S3_CACHE ] || [ ! -f "${ARTEFACT_PATH}" ]; then
  echo "INFO: building artefact ${ARTEFACT_PATH}"
  if build_artefact ; then
    echo "INFO: built artefact ${ARTEFACT_PATH}"
  else
    echo "ERROR: could not build artefact ${ARTEFACT_PATH}"
    exit 1
  fi
fi

if [ $USE_S3_CACHE ]; then
  if ! check_is_in_cache; then
    echo "INFO: No S3 cached artefact found; uploading ours now"
    if upload_to_cache; then
      echo "OK"
    else
      # NOTE: bucket might be read-only, not a fatal error!
      echo "WARN: could not upload artefact to ${ARTEFACT_S3_URL} @ ${S3_CACHE_ENDPOINT}"
    fi
  fi
fi
