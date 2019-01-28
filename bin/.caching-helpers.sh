# caching helper functions, source this in a (bash) shell script to use.

export CACHE_DIR='/tmp/leihs_build_cache'

function git_cache_key() {
  local relevant_files="${1-.}" # default=all if no arg given
  # save git output in variable to not swallow error in the pipe
  local ls_tree="$(git ls-tree HEAD -- "$relevant_files")" || exit 1
  echo "$ls_tree" | shasum -p -a 256 | cut -d' ' -f1
}

function git_repo_is_clean {
  if test -n "$(git status --porcelain)"; then
    echo "[cache]: git repo is dirty!"
    return 1
  fi
}

function save_to_cache() {
  git_repo_is_clean || return 0

  local name="$1"
  local files="$2"
  local key=$(git_cache_key "${3-.}")

  mkdir -p "${CACHE_DIR}"
  tar -cz --exclude-vcs -f "${CACHE_DIR}/${name}__${key}.tgz" $files
  sync "$CACHE_DIR"
  echo "[cache]: ($name): cached!"
}

function restore_from_cache() {
  git_repo_is_clean || return 1

  local name="$1"
  local key=$(git_cache_key ${2-.})
  local cache_file="${CACHE_DIR}/${name}__${key}.tgz"

  if test ! -f $cache_file; then
    echo "[cache]: ($name): miss!"
  else
    echo "[cache]: ($name): hit!"
    tar -xzf "$cache_file"
    sync "$CACHE_DIR"
    echo "[cache]: ($name): restored!"
    return 0
  fi
  return 1
}
