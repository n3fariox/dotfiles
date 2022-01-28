#!/bin/bash
set -e
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOL_DIR="$HOME/.local/bin"
mkdir -p "$TOOL_DIR"
TOOLS=(
    "rg" 
    "bat"
)
for tool in "${TOOLS[@]}"; do
    echo "##### Installing ${tool}"
    tar -C $TOOL_DIR -xvf "$THIS_DIR/tools.tar.gz" "$tool"
done
