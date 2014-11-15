#!/bin/bash
sudo apt-get update -qq
sudo apt-get install -y git fish

# Switch to fish as a default shell
sudo chsh -s `which fish` vagrant

# Install nvm
export METHOD=copy
/vagrant/install.sh
