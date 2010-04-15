# Node Version Manager

## Installation

To install create a folder somewhere in your filesystem with the nvm.sh file inside it.  I put mine in a folder called `.nvn`.

Then add two lines to your bash profile:

    NVM_DIR=$HOME/.nvm
    . $NVM_DIR/nvm.sh

## Usage

To download, install, and use the v0.1.91 release of node do this:

    nvm install v0.1.91

And then in any new shell just use the installed version:

    nvm use v0.1.91

If you want to track HEAD then use the clone command:

    nvm clone

Then in any new shell you can get this version with:

    nvm use HEAD

When you want to grab the latest from the node repo do:

    nvm update