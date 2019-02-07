#!/bin/bash
INSTALL_FZF=true
INSTALL_SUBLIME=false

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
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/bbashrc ~/.bbashrc
ln -sf ~/dotfiles/nanorc ~/.nanorc

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

echo "############################# Installing packages ##############################"
sudo apt install tmux git meld

if [ "$INSTALL_FZF" = true ] && [ ! -d ~/.fzf/ ]; then
    echo "################################ Installing fzf ################################"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if [ "$INSTALL_SUBLIME" = true ] && [ ! -f /usr/bin/subl ]; then
    set -e
    echo "########################### Installing sublime-text ############################"
    sudo apt install apt-transport-https
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text
    ln -s ~/dotfiles/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
    set +e
fi

if [ ! -f /usr/bin/code ]; then
    echo "########################### VS Code is not installed ###########################"
else
    echo "########################## Installing VS Code Settings #########################"
    cp vscode-settings.json ~/.config/Code/User/settings.json
    read -p "Install VS Code gitconfig (y/n)?" choice
    case "$choice" in
      y|Y ) vsgit ;;
      * ) echo "Not updating gitconfig";;
    esac
fi
