#!/bin/sh

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

echo "################################# Setup links ##################################"
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/bbashrc ~/.bbashrc

# dconf list /org/mate/terminal/ | grep profiles > /dev/null
# if [ $? -eq 0 ]; then
    # dconf dump /org/mate/terminal/profiles/profile0 > mtconf
    # dconf load /org/mate/terminal/profiles/profile0/ < mtconf
# fi

if [ -f "~/.bashrc" ]; then
    echo "################################# Setup bashrc #################################"
    append_line ~/.bashrc "source ~/.bbashrc"
    # echo "source ~/.bbashrc" >> ~/.bashrc
fi

echo "############################# Installing packages ##############################"
sudo apt install tmux git meld chromium-browser apt-transport-https

if [ ! -d ~/.fzf/ ]; then
    echo "################################ Installing fzf ################################"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

if [ ! -f /usr/bin/subl ]; then
    set -e
    echo "########################### Installing sublime-text ############################"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text
    ln -s ~/dotfiles/Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
    set +e
fi
