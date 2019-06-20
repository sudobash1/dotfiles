#!/bin/bash -e

if command -v python3.7 2>/dev/null; then
  echo "python3.7 is already installed."
fi

if ! grep -q "Ubuntu 16.04" /etc/issue; then
  echo "This is not Ubuntu 16.04"
  exit 1
fi

# From https://websiteforstudents.com/installing-the-latest-python-3-7-on-ubuntu-16-04-18-04/
echo "Compiling python3.7"
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
cd /tmp
wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
tar -xf Python-3.7.2.tar.xz
cd Python-3.7.2
./configure --enable-optimizations --prefix="$HOME/.local"
make -j $(grep -c '^cprocessor' /proc/cpuinfo)
make altinstall

echo "Installing pynvim for current user"
pip3.7 install --upgrade pynvim

echo "Setting nvim to use python3.7"
echo "
export NVIM_PYTHON3='$HOME/.local/bin/python3.7'" >> ~/.shrc.local.sh
echo "Done"
exit 0
