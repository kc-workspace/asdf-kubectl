#!/usr/bin/env bash

## mark script as failed
## e.g. `asdf_fail "cannot found git-tag command"`
asdf_fail() {
  local format="$1"
  shift

  printf "[ERR] %s: $format\n" \
    "$ASDF_PLUGIN_NAME" "$@" >&2
  exit 1
}

## log info message to stderr
## e.g. `asdf_info "found git-tag command"`
asdf_info() {
  local format="$1"
  shift

  printf "[INF] $format\n" "$@" >&2
}

## log debug message to stderr (only if $DEBUG had set)
## e.g. `asdf_debug "found git-tag command"`
asdf_debug() {
  if [ -z "${DEBUG:-}" ]; then
    return 0
  fi

  local format="$1"
  shift
  printf "[DBG] $format\n" "$@" >&2
}

## url fetch wrapper
## e.g. `asdf_fetch https://google.com`
asdf_fetch() {
  local options=()

  if command -v "curl" >/dev/null; then
    options+=(
      --fail
      --silent
      --show-error
    )

    local token="${GITHUB_API_TOKEN:-}"
    [ -z "$token" ] && token="${GITHUB_TOKEN:-}"
    [ -z "$token" ] && token="${GH_TOKEN:-}"

    if [ -n "$token" ]; then
      options+=(
        --header
        "Authorization: token $token"
      )
    fi

    curl "${options[@]}" "$@"
  fi
}

## Sorting version
## e.g. `get_versions | asdf_sort_versions`
asdf_sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

## Filtering version
## e.g. `get_versions | asdf_filter_versions "1.11"`
asdf_filter_versions() {
  local query="$1"
  grep -iE "^\\s*$query"
}

## Filtering only stable version
## e.g. `get_versions | asdf_filter_stable`
asdf_filter_stable() {
  local query='(-src|-dev|-latest|-stm|[-\.]rc|-alpha|-beta|[-\.]pre|-next|snapshot|master)'
  grep -ivE "$query"
}

## List all tags from git repository
## e.g. `asdf_list_git_tags "https://github.com/hello-world/hello-world"`
asdf_list_git_tags() {
  local repo="${1:-$ASDF_PLUGIN_APP_REPO}"

  # NOTE: You might want to adapt `sed` command to remove non-version strings from tags
  git ls-remote --tags --refs "$repo" |
    grep -o 'refs/tags/.*' |
    cut -d/ -f3- |
    sed 's/^v//'
}

## List all version sorted from git repository
## e.g. `asdf_sorted_version`
asdf_sorted_version() {
  asdf_list_git_tags | asdf_sort_versions | xargs echo
}

## get version marked as latest on Github
## e.g.`asdf_gh_latest`
asdf_gh_latest() {
  local repo="${1:-$ASDF_PLUGIN_APP_REPO}"
  local url="" version=""
  url="$(
    asdf_fetch --head "$repo/releases/latest" |
      sed -n -e "s|^location: *||p" |
      sed -n -e "s|\r||p"
  )"

  asdf_debug "redirect url: %s" "$url"
  if [[ "$url" == "$repo/releases" ]]; then
    asdf_debug "use 'tail' mode get latest version"
    version="$(asdf_sorted_version | tail -n1)"
  elif [[ "$url" != "" ]]; then
    asdf_debug "use 'gh-latest' mode get latest version"
    version="$(printf "%s\n" "$url" | sed 's|.*/tag/v\{0,1\}||')"
  fi

  [ -n "$version" ] &&
    printf "%s" "$version" ||
    return 1
}
