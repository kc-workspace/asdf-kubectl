#!/usr/bin/env bash

set -euo pipefail


export ASDF_PLUGIN_APP_NAME="kubectl"
export ASDF_PLUGIN_APP_REPO="https://github.com/kubernetes/kubectl"

## mark script as failed
## e.g. `asdf_fail cannot found git-tag command`
asdf_fail() {
  local plugin_name="asdf-kubectl"
  echo -e "$plugin_name: $*"
	exit 1
}

## log info messae to stderr
## e.g. `asdf_info found git-tag command`
asdf_info() {
  printf "%@" >&2
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

    local token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-$GH_TOKEN}}"
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

asdf_find_latest() {
  asdf_gh_latest
}

## get version marked as latest on Github
## e.g.`asdf_gh_latest`
asdf_gh_latest() {
  local repo="${1:-$ASDF_PLUGIN_APP_REPO}"
  local url="" version=""
  url="$(
    asdf_fetch --head "$repo" |
      sed -n -e "s|^location: *||p" |
      sed -n -e "s|\r||p"
  )"

  asdf_info "redirect url: %s\n" "$url"
  if [[ "$url" == "$repo/releases" ]]; then
    asdf_info "use 'tail' mode get latest version"
	  version="$(asdf_sorted_version | tail -n1)"
  else
    asdf_info "use 'gh-latest' mode get latest version"
	  version="$(printf "%s\n" "$redirect_url" | sed 's|.*/tag/v\{0,1\}||')"
  fi
}
