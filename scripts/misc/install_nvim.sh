#!/bin/sh

if [ -f /etc/issue ]; then
  # Ubuntu
  if grep -q "Ubuntu" /etc/issue; then
    # Xenial (16.04)
    if grep -q "16.04" /etc/issue; then
      echo "Installing nvim for Ubuntu 16.04"
      sudo add-apt-repository ppa:neovim-ppa/stable
      sudo apt-get update
      sudo apt-get install neovim
      echo "Making sure required python utils are installed"
      sudo apt-get install python-dev python-pip python3-dev python3-pip
      echo "Installing pynvim for current user"
      pip3 install --user --upgrade pynvim
      pip2 install --user --upgrade pynvim
      echo "Done"
      exit 0
    fi
  fi
fi

echo "Unknown Linux distro. Please install nvim manually"
echo "See https://github.com/neovim/neovim/wiki/Installing-Neovim"
