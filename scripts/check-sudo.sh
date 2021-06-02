#!/bin/bash
SCRIPT_UID=$(id -u)
if [[ "$SCRIPT_UID" != 0 ]]; then
  { which sudo >/dev/null && sudo test 1 ;} || { echo "non-root" && exit ;}
  SUDO="sudo"
fi
if [[ ! -z "$SUDO_USER" ]]; then
  echo "Don't run directly as sudo, it messes with permissions" && exit
fi
