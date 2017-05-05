#!/bin/bash
sudo apt-get update -qq
sudo apt-get install -y git fish make

# Switch to fish as a default shell
# sudo chsh -s `which fish` vagrant

# Install nvm
/vagrant/install.sh
