#!/usr/bin/env bash
set -eux

IMAGE_CACHE_DIR="/var/local/lxc_base_images/${LXC_IMAGE_CACHE_NAME}"
CACHE_KEY=$(bash -c "$LXC_IMAGE_CACHE_KEY_CMD")
CACHED_IMAGE_NAME="${LXC_CACHED_BASE_IMAGE}_${CACHE_KEY}"
IMAGE_PATH="${IMAGE_CACHE_DIR}/${CACHED_IMAGE_NAME}.tar.gz"

function cached_image_is_imported {
  lxc image show "$CACHED_IMAGE_NAME" &>/dev/null
}

function cached_image_exists {
  test -r "$IMAGE_PATH"
}

function remove_cached_image_from_lxd {
  lxc image delete "$CACHED_IMAGE_NAME"
}

function select_cached_or_base_image {
  if cached_image_is_imported; then
    echo "[LXC_IMAGE_CACHE] already imported, using cached image"
    export SELECTED_LXC_IMAGE="$CACHED_IMAGE_NAME"
  else if cached_image_exists; then
    echo "[LXC_IMAGE_CACHE] importing and using cached image"
    lxc image import ${IMAGE_PATH} --alias "$CACHED_IMAGE_NAME"
    export SELECTED_LXC_IMAGE="$CACHED_IMAGE_NAME"
  else
    echo "[LXC_IMAGE_CACHE] no cached image yet, creating from scratch"
    export SELECTED_LXC_IMAGE="${LXC_BASE_IMAGE}"
  fi; fi
}

function save_container_to_image_cache {
  if cached_image_is_imported; then
    echo "[LXC_IMAGE_CACHE] already cached and imported"
  else if cached_image_exists; then
    echo "[LXC_IMAGE_CACHE] already cached and exported"
  else
    echo "[LXC_IMAGE_CACHE] caching now!"
    mkdir -p "${IMAGE_CACHE_DIR}"
    lxc snapshot "$CONTAINER_NAME" snap0 # snapshot so we dont create image from running/changing state
    lxc publish --force "$CONTAINER_NAME"/snap0 --alias "$CACHED_IMAGE_NAME"
    lxc image export "$CACHED_IMAGE_NAME" "${IMAGE_CACHE_DIR}/${CACHED_IMAGE_NAME}"
  fi; fi
}
