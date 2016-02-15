# Node Version Manager [![Build Status](https://travis-ci.org/creationix/nvm.svg?branch=master)][3]

## Installation

First you'll need to make sure your system has a c++ compiler. For OSX, XCode will work, for Ubuntu, the build-essential and libssl-dev packages work.

Note: `nvm` does not support Windows (see [#284](https://github.com/creationix/nvm/issues/284)). Three alternatives exist, which are neither supported nor developed by us:
 - [nvm-windows](https://github.com/coreybutler/nvm-windows)
 - [nodist](https://github.com/marcelklehr/nodist)

Note: `nvm` does not support [Fish] either (see [#303](https://github.com/creationix/nvm/issues/303)). Alternatives exist, which are neither supported nor developed by us:
 - [nvm](https://github.com/derekstavis/plugin-nvm) plugin for [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish), which makes nvm and its completions available in fish shell
 - [bass](https://github.com/edc/bass) allows to use utilities written for Bash in fish shell

Note: We still have some problems with FreeBSD, because there is no pre-built binary from official for FreeBSD, and building from source may need [patches](https://www.freshports.org/www/node/files/patch-deps_v8_src_base_platform_platform-posix.cc), see the issue ticket:
 - [[#900] [Bug] nodejs on FreeBSD need to be patched ](https://github.com/creationix/nvm/issues/900)
 - [nodejs/node#3716](https://github.com/nodejs/node/issues/3716)

Note: On OSX, if you do not have XCode installed and you do not wish to download the ~4.3GB file, you can install the `Command Line Tools`. You can check out this blog post on how to just that:
 - [How to Install Command Line Tools in OS X Mavericks & Yosemite (Without Xcode)](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)

Homebrew installation is not supported.

### Install script

To install or update nvm, you can use the [install script][2] using cURL:

    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

or Wget:

    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

<sub>The script clones the nvm repository to `~/.nvm` and adds the source line to your profile (`~/.bash_profile`, `~/.zshrc` or `~/.profile`).</sub>

You can customize the install source, directory and profile using the `NVM_SOURCE`, `NVM_DIR`, and `PROFILE` variables.
Eg: `curl ... | NVM_DIR="path/to/nvm" bash`

<sub>*NB. The installer can use `git`, `curl`, or `wget` to download `nvm`, whatever is available.*</sub>

### Manual install

For manual install create a folder somewhere in your filesystem with the `nvm.sh` file inside it. I put mine in `~/.nvm`.

Or if you have `git` installed, then just clone it, and check out the latest version:

    git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`

To activate nvm, you need to source it from your shell:

    . ~/.nvm/nvm.sh

Add these lines to your `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login:

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

### Manual upgrade

For manual upgrade with `git`, change to the `$NVM_DIR`, pull down the latest changes, and check out the latest version:

    cd "$NVM_DIR" && git pull origin master && git checkout `git describe --abbrev=0 --tags`
    
After upgrading, don't forget to activate the new version:

    . "$NVM_DIR/nvm.sh"

## Usage

You can create an `.nvmrc` file containing version number in the project root directory (or any parent directory).
`nvm use`, `nvm install`, `nvm exec`, `nvm run`, and `nvm which` will all respect an `.nvmrc` file when a version is not supplied.

To download, compile, and install the latest v5.0.x release of node, do this:

    nvm install 5.0

And then in any new shell just use the installed version:

    nvm use 5.0

Or you can just run it:

    nvm run 5.0 --version

Or, you can run any arbitrary command in a subshell with the desired version of node:

    nvm exec 4.2 node --version

You can also get the path to the executable to where it was installed:

    nvm which 5.0

In place of a version pointer like "0.10" or "5.0" or "4.2.1", you can use the following special default aliases with `nvm install`, `nvm use`, `nvm run`, `nvm exec`, `nvm which`, etc:

 - `node`: this installs the latest version of [`node`](https://nodejs.org/en/)
 - `iojs`: this installs the latest version of [`io.js`](https://iojs.org/en/)
 - `stable`: this alias is deprecated, and only truly applies to `node` `v0.12` and earlier. Currently, this is an alias for `node`.
 - `unstable`: this alias points to `node` `v0.11` - the last "unstable" node release, since post-1.0, all node versions are stable. (in semver, versions communicate breakage, not stability).

If you want to install a new version of Node.js and migrate npm packages from a previous version:

    nvm install node --reinstall-packages-from=node

This will first use "nvm version node" to identify the current version you're migrating packages from. Then it resolves the new version to install from the remote server and installs it. Lastly, it runs "nvm reinstall-packages" to reinstall the npm packages from your prior version of Node to the new one.

You can also install and migrate npm packages from specific versions of Node like this:

    nvm install v5.0 --reinstall-packages-from=4.2
    nvm install v4.2 --reinstall-packages-from=iojs

If you want to install [io.js](https://github.com/iojs/io.js/):

    nvm install iojs

If you want to install a new version of io.js and migrate npm packages from a previous version:

    nvm install iojs --reinstall-packages-from=iojs

The same guidelines mentioned for migrating npm packages in Node.js are applicable to io.js.

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

    nvm alias default node

To use a mirror of the node binaries, set `$NVM_NODEJS_ORG_MIRROR`:

    export NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist
    nvm install node

    NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist nvm install 4.2

To use a mirror of the iojs binaries, set `$NVM_IOJS_ORG_MIRROR`:

    export NVM_IOJS_ORG_MIRROR=https://iojs.org/dist
    nvm install iojs-v1.0.3

    NVM_IOJS_ORG_MIRROR=https://iojs.org/dist nvm install iojs-v1.0.3

`nvm use` will not, by default, create a "current" symlink. Set `$NVM_SYMLINK_CURRENT` to "true" to enable this behavior, which is sometimes useful for IDEs.

## License

nvm is released under the MIT license.


Copyright (C) 2010-2016 Tim Caswell

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

## Compatibility Issues
`nvm` will encounter some issues if you have some non-default settings set. (see [#606](/../../issues/606))
The following are known to cause issues:

Inside `~/.npmrc`
```
prefix='some/path'
```
Environment Variables:
```
$NPM_CONFIG_PREFIX
$PREFIX
```
Shell settings:
```
set -e
```

## Problems

If you try to install a node version and the installation fails, be sure to delete the node downloads from src (~/.nvm/src/) or you might get an error when trying to reinstall them again or you might get an error like the following:

    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.

Where's my 'sudo node'? Check out this link:

https://github.com/creationix/nvm/issues/43

On Arch Linux and other systems using python3 by default, before running *install* you need to

      export PYTHON=python2

After the v0.8.6 release of node, nvm tries to install from binary packages. But in some systems, the official binary packages don't work due to incompatibility of shared libs. In such cases, use `-s` option to force install from source:

    nvm install -s 0.8.6

If setting the `default` alias does not establish the node version in new shells (i.e. `nvm current` yields `system`), ensure that the system's node PATH is set before the `nvm.sh` source line in your shell profile (see [#658](https://github.com/creationix/nvm/issues/658))

[1]: https://github.com/creationix/nvm.git
[2]: https://github.com/creationix/nvm/blob/v0.31.0/install.sh
[3]: https://travis-ci.org/creationix/nvm
[Urchin]: https://github.com/scraperwiki/urchin
[Fish]: http://fishshell.com
