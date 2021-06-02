#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
. "$THIS_DIR/check-sudo.sh"

# TODO: Ensure gnome environment, but you should know that

$SUDO apt install \
    gnome-tweaks \
    gnome-shell-extensions \
    gnome-shell-extension-arc-menu \
    gnome-shell-extension-dash-to-panel

nohup gnome-tweaks 2>/dev/null 1>&2 &

echo "
In gnome tweaks,
- Enable arc menu; load settings ($DOT_DIR/settings/arcmenu.settings)
- Enable dash panel; load settings ($DOT_DIR/settings/dash-to-panel.settings)
"
