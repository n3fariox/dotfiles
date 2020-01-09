#!/bin/bash
# First sanity check to see if we're root.
# If not, have the user enter the sudo password if available
SCRIPT_UID=$(id -u)
if [[ "$SCRIPT_UID" != 0 ]]; then
  { which sudo >/dev/null && sudo test 1 ;} || { echo "non-root" && exit ;}
  $SUDO="sudo"
fi
if [[ ! -z "$SUDO_USER" ]]; then
  echo "Don't run directly as sudo, it messes with permissions" && exit
fi
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

INSTALL_FZF=true
INSTALL_SUBLIME=false
INSTALL_NUMIX=false

LSB_RELEASE="$(lsb_release -cs)"
IS_DESKTOP=$(dpkg --get-selections | grep -e 'ubuntu-.*desktop' | wc -l)

if [ "$IS_DESKTOP" -gt 0 ]; then
    INSTALL_NUMIX=true
fi

append_line() {
  set -e

  local update line file pat lno
  update="$1"
  line="$2"
  file="$3"
  pat="${4:-}"
  lno=""

  echo "Update $file:"
  echo "  - $line"
  if [ -f "$file" ]; then
    if [ $# -lt 4 ]; then
      lno=$(\grep -nF "$line" "$file" | sed 's/:.*//' | tr '\n' ' ')
    else
      lno=$(\grep -nF "$pat" "$file" | sed 's/:.*//' | tr '\n' ' ')
    fi
  fi
  if [ -n "$lno" ]; then
    echo "    - Already exists: line #$lno"
  else
    if [ $update -eq 1 ]; then
      [ -f "$file" ] && echo >> "$file"
      echo "$line" >> "$file"
      echo "    + Added"
    else
      echo "    ~ Skipped"
    fi
  fi
  echo
  set +e
}

vsgit() {
    git config --global core.editor "code --wait"
    git config --global merge.tool vscode
    git config --global diff.tool vscode
}

echo "################################# Setup links ##################################"
case $(tmux -V | cut -d " " -f 2) in
*)
    ln -sf $THIS_DIR/tmux.conf ~/.tmux.conf
    ;;
esac
mkdir -p ~/.tmux/
# ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
# ln -sf ~/dotfiles/tmux-powerline.conf ~/.tmux/tmux-powerline.conf
ln -sf $THIS_DIR/gitconfig ~/.gitconfig
ln -sf $THIS_DIR/bbashrc ~/.bbashrc
ln -sf $THIS_DIR/nanorc ~/.nanorc

# dconf list /org/mate/terminal/ | grep profiles > /dev/null
# if [ $? -eq 0 ]; then
    # dconf dump /org/mate/terminal/profiles/profile0 > mtconf
    # dconf load /org/mate/terminal/profiles/profile0/ < mtconf
# fi

if [ -f "$HOME/.bashrc" ]; then
    echo "################################# Setup bashrc #################################"
    append_line 1 "source ~/.bbashrc" ~/.bashrc
fi

if [ -x "$(command -v xdg-user-dirs-update)" ]; then
    echo "############################## Updating homedirs... #############################"
    if [ $(xdg-user-dir DESKTOP) != "$HOME/desktop" ]; then
        echo "Setting desktop folder..."
        mv $(xdg-user-dir DESKTOP) $HOME/desktop
        xdg-user-dirs-update --set DESKTOP $HOME/desktop
    fi
    if [ $(xdg-user-dir DOWNLOAD) != "$HOME/downloads" ]; then
        echo "Setting download folder..."
        mv $(xdg-user-dir DOWNLOAD) $HOME/downloads
        xdg-user-dirs-update --set DOWNLOAD $HOME/downloads
        # TODO: need to set the bluetooth setting if possible
    fi
    echo "Consolidating media directories..."
    mkdir -p $HOME/media
    xdg-user-dirs-update --set DOCUMENTS $HOME/media
    xdg-user-dirs-update --set MUSIC $HOME/media
    xdg-user-dirs-update --set PICTURES $HOME/media
    xdg-user-dirs-update --set VIDEOS $HOME/media
    echo "Disabling unused directories..."
    xdg-user-dirs-update --set TEMPLATES $HOME
    xdg-user-dirs-update --set PUBLICSHARE $HOME
    echo "Updating directory registry..."
    xdg-user-dirs-update
    echo "Attempting to remove default user dirs..."
    rmdir $HOME/Download 2>/dev/null
    rmdir $HOME/Documents 2>/dev/null
    rmdir $HOME/Music 2>/dev/null
    rmdir $HOME/Pictures  2>/dev/null
    rmdir $HOME/Videos 2>/dev/null
    rmdir $HOME/Templates 2>/dev/null
    rmdir $HOME/Public 2>/dev/null

fi

if [ -x "$(command -v apt-get)" ]; then
  echo "############################# Installing apt packages ##########################"
  INSTALLS="tmux git"
  if [ "$IS_DESKTOP" -gt 0 ]; then
      INSTALLS="$INSTALLS meld"
  fi
  # case $LSB_RELEASE in
  #     bionic)
  #         INSTALLS="$INSTALLS powerline"
  #     ;;
  # esac
  $SUDO apt-get install $INSTALLS
fi

if [ "$INSTALL_FZF" = true ] && [ ! -d ~/.fzf/ ]; then
    echo "################################ Installing fzf ################################"
    # git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    # ~/.fzf/install
    tar xvzf $THIS_DIR/fzf-bin.tar.gz >/dev/null && $THIS_DIR/install-fzf --all
fi

if [ "$INSTALL_SUBLIME" = true ] && [ ! -f /usr/bin/subl ]; then
    set -e
    echo "########################### Installing sublime-text ############################"
    $SUDO apt-get install apt-transport-https
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | $SUDO apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable" | $SUDO tee /etc/apt/sources.list.d/sublime-text.list
    $SUDO apt-get update
    $SUDO apt-get install sublime-text
    ln -s $THIS_DIR/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
    git config --global core.editor "subl -n -w"
    set +e
fi

if [ -x "$(command -v code)"]; then
    echo "########################### VS Code is not installed ###########################"
else
    echo "########################## Installing VS Code Settings #########################"
    cp $THIS_DIR/vscode-settings.json ~/.config/Code/User/settings.json
    cp $THIS_DIR/vscode-keybindings.json ~/.config/Code/User/keybindings.json
    read -p "Install VS Code gitconfig (y/n)?" choice
    case "$choice" in
      y|Y ) vsgit ;;
      * ) echo "Not updating gitconfig";;
    esac
fi

if [ "$INSTALL_NUMIX" = true ]; then
    # Should probably look for a window manager...oh well
    sudo tar xvf $THIS_DIR/numix-gtk-theme.tar.gz
fi
