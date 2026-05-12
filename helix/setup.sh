#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mise use -g node@latest
mise reshim
npm install -g \
  dockerfile-language-server-nodejs \
  @microsoft/compose-language-service \
  bash-language-server \
  pyright \
  yaml-language-server@next

if command -v mise &>/dev/null || declare -F "mise" &>/dev/null; then
  echo "Linking helix mise config"
  mkdir -p "${HOME}/.config/mise/conf.d/"
  ln -sf "${THIS_DIR}/tools.toml" "${HOME}/.config/mise/conf.d/51-helix.toml"
fi
