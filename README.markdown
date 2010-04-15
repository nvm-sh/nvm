# Node Version Manager

## Installation

First you'll need to make sure your system has a c++ compiler.  For OSX, XCode will work, for Ubuntu, the build-essential package works.  You'll also need `git` if you want to track HEAD.

To install create a folder somewhere in your filesystem with the nvm.sh file inside it.  I put mine in a folder called `.nvm`.

Then add three lines to your bash profile:

    NVM_DIR=$HOME/.nvm
    . $NVM_DIR/nvm.sh
    nvm use v0.1.91

The first line tells your system where NVM is installed, you should already have nvm.sh there.  The second line loads the nvm function into your bash shell so that it's available as a command.  The third line sets your default node version.

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

If you want to see what versions you have installed issue:

   nvm list