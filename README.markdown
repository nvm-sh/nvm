# Node Version Manager [![Build Status](https://travis-ci.org/creationix/nvm.svg?branch=master)][3]

## Installation

First you'll need to make sure your system has a c++ compiler. For OSX, XCode will work, for Ubuntu, the build-essential and libssl-dev packages work.

Note: `nvm` does not support Windows (see [#284](https://github.com/creationix/nvm/issues/284)). Two alternatives exist, which are not supported nor developed by us:
 - [nvmw](https://github.com/hakobera/nvmw)
 - [nvm-windows](https://github.com/coreybutler/nvm-windows)

Note: `nvm` does not support [Fish] either (see [#303](https://github.com/creationix/nvm/issues/303)). Two alternatives exist, which are not supported nor developed by us:
 - [nvm-fish-wrapper](https://github.com/passcod/nvm-fish-wrapper)
 - [nvm-fish](https://github.com/Alex7Kom/nvm-fish) (does not support iojs)

### Install script

To install you could use the [install script][2] using cURL:

    curl https://raw.githubusercontent.com/creationix/nvm/v0.24.2/install.sh | bash

or Wget:

    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.24.2/install.sh | bash

<sub>The script clones the nvm repository to `~/.nvm` and adds the source line to your profile (`~/.bash_profile`, `~/.zshrc` or `~/.profile`).</sub>

You can customize the install source, directory and profile using the `NVM_SOURCE`, `NVM_DIR`, and `PROFILE` variables.
Eg: `curl ... | NVM_DIR=/usr/local/nvm bash` for a global install.

<sub>*NB. The installer can use `git`, `curl`, or `wget` to download `nvm`, whatever is available.*</sub>

### Manual install

For manual install create a folder somewhere in your filesystem with the `nvm.sh` file inside it. I put mine in a folder called `nvm`.

Or if you have `git` installed, then just clone it, and check out the latest version:

    git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`

To activate nvm, you need to source it from your shell:

    source ~/.nvm/nvm.sh

I always add this line to my `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login.
Often I also put in a line to use a specific version of node.

## Usage

You can create an `.nvmrc` file containing version number in the project root directory (or any parent directory).
`nvm use`, `nvm install`, `nvm exec`, `nvm run`, and `nvm which` will all respect an `.nvmrc` file when a version is not supplied.

To download, compile, and install the latest v0.10.x release of node, do this:

    nvm install 0.10

And then in any new shell just use the installed version:

    nvm use 0.10

Or you can just run it:

    nvm run 0.10 --version

Or, you can run any arbitrary command in a subshell with the desired version of node:

    nvm exec 0.10 node --version

You can also get the path to the executable to where it was installed:

    nvm which 0.10

In place of a version pointer like "0.10", you can use the special default aliases "stable" and "unstable":

    nvm install stable
    nvm install unstable
    nvm use stable
    nvm run unstable --version

If you want to install [io.js](https://github.com/iojs/io.js/):

    nvm install iojs

If you want to use the system-installed version of node, you can use the special default alias "system":

    nvm use system
    nvm run system --version

If you want to see what versions are installed:

    nvm ls

If you want to see what versions are available to install:

    nvm ls-remote

To restore your PATH, you can deactivate it.

    nvm deactivate

To set a default Node version to be used in any new shell, use the alias 'default':

    nvm alias default stable

To use a mirror of the node binaries, set `$NVM_NODEJS_ORG_MIRROR`:

    export NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist
    nvm install 0.10

    NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist nvm install 0.10

To use a mirror of the iojs binaries, set `$NVM_IOJS_ORG_MIRROR`:

    export NVM_IOJS_ORG_MIRROR=https://iojs.org/dist
    nvm install iojs-v1.0.3

    NVM_IOJS_ORG_MIRROR=https://iojs.org/dist nvm install iojs-v1.0.3

`nvm use` will not, by default, create a "current" symlink. Set `$NVM_SYMLINK_CURRENT` to "true" to enable this behavior, which is sometimes useful for IDEs.

## License

nvm is released under the MIT license.


Copyright (C) 2010-2014 Tim Caswell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Running tests
Tests are written in [Urchin]. Install Urchin (and other dependencies) like so:

    npm install

There are slow tests and fast tests. The slow tests do things like install node
and check that the right versions are used. The fast tests fake this to test
things like aliases and uninstalling. From the root of the nvm git repository,
run the fast tests like this.

    npm run test/fast

Run the slow tests like this.

    npm run test/slow

Run all of the tests like this

    npm test

Nota bene: Avoid running nvm while the tests are running.

## Bash completion

To activate, you need to source `bash_completion`:

  	[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

Put the above sourcing line just below the sourcing line for NVM in your profile (`.bashrc`, `.bash_profile`).

### Usage

nvm

	$ nvm [tab][tab]
    alias               deactivate          install             ls                  run                 unload
    clear-cache         exec                list                ls-remote           unalias             use
    current             help                list-remote         reinstall-packages  uninstall           version

nvm alias

	$ nvm alias [tab][tab]
	default

	$ nvm alias my_alias [tab][tab]
	v0.6.21        v0.8.26       v0.10.28

nvm use

	$ nvm use [tab][tab]
	my_alias        default        v0.6.21        v0.8.26       v0.10.28

nvm uninstall

	$ nvm uninstall [tab][tab]
	my_alias        default        v0.6.21        v0.8.26       v0.10.28

## Problems

If you try to install a node version and the installation fails, be sure to delete the node downloads from src (~/.nvm/src/) or you might get an error when trying to reinstall them again or you might get an error like the following:

    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.

Where's my 'sudo node'? Check out this link:

https://github.com/creationix/nvm/issues/43

On Arch Linux and other systems using python3 by default, before running *install* you need to

      export PYTHON=python2

After the v0.8.6 release of node, nvm tries to install from binary packages. But in some systems, the official binary packages don't work due to incompatibility of shared libs. In such cases, use `-s` option to force install from source:

    nvm install -s 0.8.6

[1]: https://github.com/creationix/nvm.git
[2]: https://github.com/creationix/nvm/blob/v0.24.2/install.sh
[3]: https://travis-ci.org/creationix/nvm
[Urchin]: https://github.com/scraperwiki/urchin
[Fish]: http://fishshell.com
