# Node Version Manager

## Installation

First you'll need to make sure your system has a c++ compiler.  For OSX, XCode will work, for Ubuntu, the build-essential and libssl-dev packages work.

To install create a folder somewhere in your filesystem with the "`nvm.sh`" file inside it.  I put mine in a folder called "`.nvm`".

Or if you have `git` installed, then just clone it:

    git clone git://github.com/creationix/nvm.git ~/.nvm

To activate nvm, you need to source it from your bash shell

    . ~/.nvm/nvm.sh
    
## Usage

To download, install, and use the v0.2.5 release of node do this:

    nvm install v0.2.5

And then in any new shell just use the installed version:

    nvm use v0.2.5

If you want to see what versions you have installed issue:

    nvm ls

To restore your PATH, you can deactivate it.

    nvm deactivate

