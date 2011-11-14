# Node Version Manager

## Installation

First you'll need to make sure your system has a c++ compiler.  For OSX, XCode will work, for Ubuntu, the build-essential and libssl-dev packages work.

To install create a folder somewhere in your filesystem with the "`nvm.sh`" file inside it.  I put mine in a folder called "`.nvm`".

Or if you have `git` installed, then just clone it:

    git clone git://github.com/creationix/nvm.git ~/.nvm

To activate nvm, you need to source it from your bash shell

    . ~/.nvm/nvm.sh

I always add this line to my ~/.bashrc or ~/.profile file to have it automatically sources upon login.   
Often I also put in a line to use a specific version of node.
    
## Usage

To download, compile, and install the v0.4.1 release of node, do this:

    nvm install v0.4.1

And then in any new shell just use the installed version:

    nvm use v0.4.1

If you want to see what versions are available:

    nvm ls

To restore your PATH, you can deactivate it.

    nvm deactivate

To set a default Node version to be used in any new shell, use the alias 'default':

    nvm alias default v0.4.1

## Problems

If you try to install a node version and the installation fails, be sure to delete the node downloads from src (~/.nvm/src/) or you might get an error when trying to reinstall them again or you might get an error like the following:
    
    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.
