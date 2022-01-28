#!/bin/bash
set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Setup temp environment and always clean up
    THIS_TMP="$THIS_DIR/.tmp"
    mkdir -p "$THIS_TMP"
    pushd "$THIS_DIR" 1>/dev/null || exit
    function bail()
    {
        rm -rf "$THIS_TMP" 2>/dev/null 1>&2
        popd 1>/dev/null 2>/dev/null
        exit
    }
    trap bail EXIT

TOOLS_TAR_GZ="$THIS_DIR/tools.tar.gz"
TOOLS_MANIFEST="$THIS_DIR/tools.txt"
touch "$TOOLS_MANIFEST"


function latest_github_release()
{
    # $1 = github url to a project, including https
    local latest_version latest_release
    latest_release=$(curl -L -s -H 'Accept: application/json' "$1/releases/latest")
    latest_version=$(echo "$latest_release" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    echo "$latest_version"
}

function update_manifest()
{
    sed -i "/^${1}=/{h;s/=.*/=${2}/};\${x;/^$/{s//${1}=${2}/;H};x}" ${TOOLS_MANIFEST}
}

function get_rust_project()
{
    # https://github.com/sharkdp/bat/releases/download/v0.19.0/bat-v0.19.0-x86_64-unknown-linux-gnu.tar.gz
    local tool_name="$1"
    local github_project="$2"
    local long_name="${3:-$1}"
    local dist="${4:-x86_64-unknown-linux-gnu}"
    local latest_version url folder_name
    echo "##### Downloading ${long_name} #####"
    latest_version=$(latest_github_release $github_project)
    folder_name="$long_name-$latest_version-$dist"
    url="$github_project/releases/download/$latest_version/$folder_name.tar.gz"
    curl -L "$url" -o "$THIS_TMP/$tool_name.tar.gz"
    tar -C "$THIS_TMP" --strip-components 1 -xvf "$THIS_TMP/$tool_name.tar.gz" "$folder_name/$tool_name"
    tar -C "$THIS_TMP" -vuf "$TOOLS_TAR_GZ" "$tool_name"
    update_manifest "${tool_name}" "${latest_version}"
}

function get_go_project()
{
    local tool_name="$1"
    local github_project="$2"
    local long_name="${3:-$1}"
    local dist="${4:-linux_amd64}"
    local latest_version url folder_name
    echo "##### Downloading ${long_name} #####"
    latest_version=$(latest_github_release $github_project)
    folder_name="$long_name-$latest_version-$dist"
    url="$github_project/releases/download/$latest_version/$folder_name.tar.gz"
    curl -L "$url" -o "$THIS_TMP/$tool_name.tar.gz"
    tar -C "$THIS_TMP" -xvf "$THIS_TMP/$tool_name.tar.gz" "$tool_name"
    tar -C "$THIS_TMP" -vuf "$TOOLS_TAR_GZ" "$tool_name"
    update_manifest "${tool_name}" "${latest_version}"
}

function update_fzf()
{
    local tool_name="fzf"
    local github_project="https://github.com/junegunn/fzf"
    local long_name="fzf"
    local dist="${1:-linux_amd64}"
    local latest_version url folder_name
    echo "##### Downloading ${long_name} #####"
    latest_version=$(latest_github_release $github_project)
    folder_name="$long_name-$latest_version-$dist"
    url="$github_project/releases/download/$latest_version/$folder_name.tar.gz"
    curl -L "$url" -o "$THIS_TMP/$tool_name.tar.gz"
    tar -C "$THIS_TMP" -xvf "$THIS_TMP/$tool_name.tar.gz" "$tool_name"
    tar -C "$THIS_TMP" -vuf "$TOOLS_TAR_GZ" "$tool_name"
    update_manifest "${tool_name}" "${latest_version}"

    # Now we need to update the install scripts
    git clone -q --depth=1 -b "$latest_version" "$github_project" "$THIS_TMP/fzfrepo" 2>/dev/null || true
    pushd "$THIS_TMP/fzfrepo"
    tar -cvzf "$THIS_DIR/fzf.tar.gz" install shell/*
    popd
}

get_rust_project "bat" "https://github.com/sharkdp/bat"
get_rust_project "rg" "https://github.com/BurntSushi/ripgrep" "ripgrep" "x86_64-unknown-linux-musl"
update_fzf ""
