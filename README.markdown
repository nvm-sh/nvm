# Node Version Manager

## Installation

First you'll need to make sure your system has a c++ compiler.  For OSX, XCode will work, for Ubuntu, the build-essential package works.  You'll also need `git` if you want to track HEAD.

To install create a folder somewhere in your filesystem with the "`nvm.sh`" file inside it.  I put mine in a folder called "`.nvm`".

Or if you have `git` installed, then just clone it:

    git clone git://github.com/creationix/nvm.git ~/.nvm

Then add two lines to your bash profile:

    export $NVM_DIR=$HOME/.nvm
    . $NVM_DIR/nvm.sh
    nvm use

The first line loads the `nvm` function into your bash shell so that it's available as a command.  The second line sets your default node version to the latest released version.

## Usage

To download, install, and use the v0.1.94 release of node do this:

    nvm install v0.1.94

And then in any new shell just use the installed version:

    nvm use v0.1.94

If you want to track HEAD then use the clone command:

    nvm clone

Then in any new shell you can get this version with:

    nvm use HEAD

When you want to grab the latest from the node repo do:

    nvm update

If you want to see what versions you have installed issue:

    nvm list

If you want to install nvm to somewhere other than `$HOME/.nvm`, then set the `$NVM_DIR` environment variable before sourcing the nvm.sh file.