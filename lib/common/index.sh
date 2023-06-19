#!/usr/bin/env bash

## Environment variables
## https://asdf-vm.com/plugins/create.html#environment-variables-overview

# shellcheck source-path=SCRIPTDIR/defaults.sh
source "${KC_ASDF_PLUGIN_PATH:?}/lib/common/defaults.sh"
# shellcheck source-path=SCRIPTDIR/internal.sh
source "${KC_ASDF_PLUGIN_PATH:?}/lib/common/internal.sh"

## System information
KC_ASDF_OS="$(kc_asdf_get_os)"
KC_ASDF_ARCH="$(kc_asdf_get_arch)"
## Plugin information
KC_ASDF_ORG="kc-workspace"
KC_ASDF_NAME="asdf-kubectl"
KC_ASDF_REPO="https://github.com/kc-workspace/asdf-kubectl"
## Application information
KC_ASDF_APP_NAME="kubectl"
KC_ASDF_APP_DESC="a commandline interface for kubernetes cluster"
KC_ASDF_APP_REPO="https://github.com/kubernetes/kubernetes"
## Download settings
KC_ASDF_DOWNLOAD_URL="https://dl.k8s.io/release/v{version}/bin/{os}/{arch}/kubectl"
KC_ASDF_DOWNLOAD_NAME="kubectl"
KC_ASDF_CHECKSUM_URL="https://dl.k8s.io/v{version}/bin/{os}/{arch}/kubectl.sha256"
KC_ASDF_DOWNLOAD_LOC=""

## These are set on bin/* scripts
# export KC_ASDF_PLUGIN_ENTRY_PATH
# export KC_ASDF_PLUGIN_ENTRY_NAME
# export KC_ASDF_PLUGIN_PATH
export KC_ASDF_APP_NAME KC_ASDF_APP_DESC KC_ASDF_APP_REPO
export KC_ASDF_DOWNLOAD_URL KC_ASDF_DOWNLOAD_NAME KC_ASDF_DOWNLOAD_LOC
export KC_ASDF_CHECKSUM_URL
export KC_ASDF_ORG KC_ASDF_NAME KC_ASDF_REPO
export KC_ASDF_OS KC_ASDF_ARCH
