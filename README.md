# Node Version Manager [![Build Status](https://travis-ci.org/creationix/nvm.svg?branch=master)][3] [![nvm version](https://img.shields.io/badge/version-v0.33.6-yellow.svg)][4] [![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/684/badge)](https://bestpractices.coreinfrastructure.org/projects/684)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Installation](#installation)
  - [Install script](#install-script)
  - [Verify installation](#verify-installation)
  - [Important Notes](#important-notes)
  - [Git install](#git-install)
  - [Manual Install](#manual-install)
  - [Manual upgrade](#manual-upgrade)
- [Usage](#usage)
  - [Long-term support](#long-term-support)
  - [Migrating global packages while installing](#migrating-global-packages-while-installing)
  - [Default global packages from file while installing](#default-global-packages-from-file-while-installing)
  - [io.js](#iojs)
  - [System version of node](#system-version-of-node)
  - [Listing versions](#listing-versions)
  - [.nvmrc](#nvmrc)
  - [Deeper Shell Integration](#deeper-shell-integration)
    - [zsh](#zsh)
      - [Calling `nvm use` automatically in a directory with a `.nvmrc` file](#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file)
- [License](#license)
- [Running tests](#running-tests)
- [Bash completion](#bash-completion)
  - [Usage](#usage-1)
- [Compatibility Issues](#compatibility-issues)
- [Installing nvm on Alpine Linux](#installing-nvm-on-alpine-linux)
- [Docker for development environment](#docker-for-development-environment)
- [Problems](#problems)
- [Mac OS "troubleshooting"](#mac-os-troubleshooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

### Install script

To install or update nvm, you can use the [install script][2] using cURL:

```sh
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
```

or Wget:

```sh
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
```

<sub>The script clones the nvm repository to `~/.nvm` and adds the source line to your profile (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`).</sub>

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```

You can customize the install source, directory, profile, and version using the `NVM_SOURCE`, `NVM_DIR`, `PROFILE`, and `NODE_VERSION` variables.
Eg: `curl ... | NVM_DIR=/usr/local/nvm bash` for a global install.

<sub>*NB. The installer can use `git`, `curl`, or `wget` to download `nvm`, whatever is available.*</sub>

**Note:** On Linux, after running the install script, if you get `nvm: command not found` or see no feedback from your terminal after you type:

```sh
command -v nvm
```
simply close your current terminal, open a new terminal, and try verifying again.

**Note:** On OS X, if you get `nvm: command not found` after running the install script, one of the following might be the reason:-
 - your system may not have a [`.bash_profile file`] where the command is set up. Simply create one with `touch ~/.bash_profile` and run the install script again
 - you might need to restart your terminal instance. Try opening a new tab/window in your terminal and retry.

If the above doesn't fix the problem, open your `.bash_profile` and add the following line of code:

`source ~/.bashrc`

- For more information about this issue and possible workarounds, please [refer here](https://github.com/creationix/nvm/issues/576)

### Verify installation

To verify that nvm has been installed, do:

```sh
command -v nvm
```

which should output 'nvm' if the installation was successful. Please note that `which nvm` will not work, since `nvm` is a sourced shell function, not an executable binary.

### Important Notes

If you're running a system without prepackaged binary available, which means you're going to install nodejs or io.js from its source code, you need to make sure your system has a C++ compiler. For OS X, Xcode will work, for Debian/Ubuntu based GNU/Linux, the `build-essential` and `libssl-dev` packages work.

**Note:** `nvm` does not support Windows (see [#284](https://github.com/creationix/nvm/issues/284)). Two alternatives exist, which are neither supported nor developed by us:
 - [nvm-windows](https://github.com/coreybutler/nvm-windows)
 - [nodist](https://github.com/marcelklehr/nodist)

**Note:** `nvm` does not support [Fish] either (see [#303](https://github.com/creationix/nvm/issues/303)). Alternatives exist, which are neither supported nor developed by us:
 - [bass](https://github.com/edc/bass) allows you to use utilities written for Bash in fish shell
 - [fast-nvm-fish](https://github.com/brigand/fast-nvm-fish) only works with version numbers (not aliases) but doesn't significantly slow your shell startup
 - [plugin-nvm](https://github.com/derekstavis/plugin-nvm) plugin for [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish), which makes nvm and its completions available in fish shell
 - [fnm](https://github.com/fisherman/fnm) - [fisherman](https://github.com/fisherman/fisherman)-based version manager for fish 

**Note:** We still have some problems with FreeBSD, because there is no official pre-built binary for FreeBSD, and building from source may need [patches](https://www.freshports.org/www/node/files/patch-deps_v8_src_base_platform_platform-posix.cc); see the issue ticket:
 - [[#900] [Bug] nodejs on FreeBSD may need to be patched ](https://github.com/creationix/nvm/issues/900)
 - [nodejs/node#3716](https://github.com/nodejs/node/issues/3716)

**Note:** On OS X, if you do not have Xcode installed and you do not wish to download the ~4.3GB file, you can install the `Command Line Tools`. You can check out this blog post on how to just that:
 - [How to Install Command Line Tools in OS X Mavericks & Yosemite (Without Xcode)](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)

**Note:** On OS X, if you have/had a "system" node installed and want to install modules globally, keep in mind that:
 - When using nvm you do not need `sudo` to globally install a module with `npm -g`, so instead of doing `sudo npm install -g grunt`, do instead `npm install -g grunt`
 - If you have an `~/.npmrc` file, make sure it does not contain any `prefix` settings (which is not compatible with nvm)
 - You can (but should not?) keep your previous "system" node install, but nvm will only be available to your user account (the one used to install nvm). This might cause version mismatches, as other users will be using `/usr/local/lib/node_modules/*` VS your user account using `~/.nvm/versions/node/vX.X.X/lib/node_modules/*`

Homebrew installation is not supported. If you have issues with homebrew-installed `nvm`, please `brew uninstall` it, and install it using the instructions below, before filing an issue.

**Note:** If you're using `zsh` you can easily install `nvm` as a zsh plugin. Install [`zsh-nvm`](https://github.com/lukechilds/zsh-nvm) and run `nvm upgrade` to upgrade.

**Note:** Git versions before v1.7 may face a problem of cloning nvm source from GitHub via https protocol, and there is also different behavior of git before v1.6, so the minimum required git version is v1.7.0 and we recommend v1.7.9.5 as it's the default version of the widely used Ubuntu 12.04 LTS. If you are interested in the problem we mentioned here, please refer to GitHub's [HTTPS cloning errors](https://help.github.com/articles/https-cloning-errors/) article.

### Git install

If you have `git` installed (requires git v1.7+):

1. clone this repo in the root of your user profile
  - `cd ~/` from anywhere then `git clone https://github.com/creationix/nvm.git .nvm`
2. `cd ~/.nvm` and check out the latest version with `git checkout v0.33.6`
3. activate nvm by sourcing it from your shell: `. nvm.sh`

Now add these lines to your `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login:
(you may have to add to more than one of the above files)

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

### Manual Install

For a fully manual install, create a folder somewhere in your filesystem with the `nvm.sh` file inside it. I put mine in `~/.nvm` and added the following to the `nvm.sh` file.

```sh
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/creationix/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"
```

Now add these lines to your `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login:
(you may have to add to more than one of the above files)

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```

### Manual upgrade

For manual upgrade with `git` (requires git v1.7+):

1. change to the `$NVM_DIR`
1. pull down the latest changes
1. check out the latest version
1. activate the new version

```sh
(
  cd "$NVM_DIR"
  git fetch origin
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
) && . "$NVM_DIR/nvm.sh"
```

## Usage

To download, compile, and install the latest release of node, do this:

```sh
nvm install node
```

And then in any new shell just use the installed version:

```sh
nvm use node
```

Or you can just run it:

```sh
nvm run node --version
```
Or, you can run any arbitrary command in a subshell with the desired version of node:

```sh
nvm exec 4.2 node --version
```

You can also get the path to the executable to where it was installed:

```sh
nvm which 5.0
```

In place of a version pointer like "0.10" or "5.0" or "4.2.1", you can use the following special default aliases with `nvm install`, `nvm use`, `nvm run`, `nvm exec`, `nvm which`, etc:

 - `node`: this installs the latest version of [`node`](https://nodejs.org/en/)
 - `iojs`: this installs the latest version of [`io.js`](https://iojs.org/en/)
 - `stable`: this alias is deprecated, and only truly applies to `node` `v0.12` and earlier. Currently, this is an alias for `node`.
 - `unstable`: this alias points to `node` `v0.11` - the last "unstable" node release, since post-1.0, all node versions are stable. (in semver, versions communicate breakage, not stability).

### Long-term support
Node has a [schedule](https://github.com/nodejs/LTS#lts_schedule) for long-term support (LTS) You can reference LTS versions in aliases and `.nvmrc` files with the notation `lts/*` for the latest LTS, and `lts/argon` for LTS releases from the "argon" line, for example. In addition, the following commands support LTS arguments:
 - `nvm install --lts` / `nvm install --lts=argon` / `nvm install 'lts/*'` / `nvm install lts/argon`
 - `nvm uninstall --lts` / `nvm uninstall --lts=argon` / `nvm uninstall 'lts/*'` / `nvm uninstall lts/argon`
 - `nvm use --lts` / `nvm use --lts=argon` / `nvm use 'lts/*'` / `nvm use lts/argon`
 - `nvm exec --lts` / `nvm exec --lts=argon` / `nvm exec 'lts/*'` / `nvm exec lts/argon`
 - `nvm run --lts` / `nvm run --lts=argon` / `nvm run 'lts/*'` / `nvm run lts/argon`
 - `nvm ls-remote --lts` / `nvm ls-remote --lts=argon` `nvm ls-remote 'lts/*'` / `nvm ls-remote lts/argon`
 - `nvm version-remote --lts` / `nvm version-remote --lts=argon` / `nvm version-remote 'lts/*'` / `nvm version-remote lts/argon`

Any time your local copy of `nvm` connects to https://nodejs.org, it will re-create the appropriate local aliases for all available LTS lines. These aliases (stored under `$NVM_DIR/alias/lts`), are managed by `nvm`, and you should not modify, remove, or create these files - expect your changes to be undone, and expect meddling with these files to cause bugs that will likely not be supported.

### Migrating global packages while installing
If you want to install a new version of Node.js and migrate npm packages from a previous version:

```sh
nvm install node --reinstall-packages-from=node
```

This will first use "nvm version node" to identify the current version you're migrating packages from. Then it resolves the new version to install from the remote server and installs it. Lastly, it runs "nvm reinstall-packages" to reinstall the npm packages from your prior version of Node to the new one.

You can also install and migrate npm packages from specific versions of Node like this:

```sh
nvm install 6 --reinstall-packages-from=5
nvm install v4.2 --reinstall-packages-from=iojs
```

### Default global packages from file while installing

If you have a list of default packages you want installed every time you install a new version we support that too. You can add anything npm would accept as a package argument on the command line.

```sh
# $NVM_DIR/default-packages

rimraf
object-inspect@1.0.2
stevemao/left-pad
```

### io.js
If you want to install [io.js](https://github.com/iojs/io.js/):

```sh
nvm install iojs
```

If you want to install a new version of io.js and migrate npm packages from a previous version:

```sh
nvm install iojs --reinstall-packages-from=iojs
```

The same guidelines mentioned for migrating npm packages in Node.js are applicable to io.js.

### System version of node
If you want to use the system-installed version of node, you can use the special default alias "system":

```sh
nvm use system
nvm run system --version
```

### Listing versions
If you want to see what versions are installed:

```sh
nvm ls
```

If you want to see what versions are available to install:

```sh
nvm ls-remote
```

To restore your PATH, you can deactivate it:

```sh
nvm deactivate
```

To set a default Node version to be used in any new shell, use the alias 'default':

```sh
nvm alias default node
```

To use a mirror of the node binaries, set `$NVM_NODEJS_ORG_MIRROR`:

```sh
export NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist
nvm install node

NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist nvm install 4.2
```

To use a mirror of the io.js binaries, set `$NVM_IOJS_ORG_MIRROR`:

```sh
export NVM_IOJS_ORG_MIRROR=https://iojs.org/dist
nvm install iojs-v1.0.3

NVM_IOJS_ORG_MIRROR=https://iojs.org/dist nvm install iojs-v1.0.3
```

`nvm use` will not, by default, create a "current" symlink. Set `$NVM_SYMLINK_CURRENT` to "true" to enable this behavior, which is sometimes useful for IDEs. Note that using `nvm` in multiple shell tabs with this environment variable enabled can cause race conditions.

### .nvmrc

You can create a `.nvmrc` file containing version number in the project root directory (or any parent directory).
`nvm use`, `nvm install`, `nvm exec`, `nvm run`, and `nvm which` will all respect an `.nvmrc` file when a version is not supplied.

For example, to make nvm default to the latest 5.9 release for the current directory:

```sh
$ echo "5.9" > .nvmrc

$ echo "lts/*" > .nvmrc # to default to the latest LTS version
```

Then when you run nvm:

```sh
$ nvm use
Found '/path/to/project/.nvmrc' with version <5.9>
Now using node v5.9.1 (npm v3.7.3)
```

### Deeper Shell Integration

You can use [`avn`](https://github.com/wbyoung/avn) to deeply integrate into your shell and automatically invoke `nvm` when changing directories. `avn` is **not** supported by the `nvm` development team. Please [report issues to the `avn` team](https://github.com/wbyoung/avn/issues/new).

If you prefer a lighter-weight solution, the recipes below have been contributed by `nvm` users. They are **not** supported by the `nvm` development team. We are, however, accepting pull requests for more examples.

#### zsh

##### Calling `nvm use` automatically in a directory with a `.nvmrc` file

Put this into your `$HOME/.zshrc` to call `nvm use` automatically whenever you enter a directory that contains an
`.nvmrc` file with a string telling nvm which node to `use`:

```zsh
# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

## License

nvm is released under the MIT license.


Copyright (C) 2010-2017 Tim Caswell and Jordan Harband

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Running tests
Tests are written in [Urchin]. Install Urchin (and other dependencies) like so:

    npm install

There are slow tests and fast tests. The slow tests do things like install node
and check that the right versions are used. The fast tests fake this to test
things like aliases and uninstalling. From the root of the nvm git repository,
run the fast tests like this:

    npm run test/fast

Run the slow tests like this:

    npm run test/slow

Run all of the tests like this:

    npm test

Nota bene: Avoid running nvm while the tests are running.

## Bash completion

To activate, you need to source `bash_completion`:

```sh
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion
```

Put the above sourcing line just below the sourcing line for nvm in your profile (`.bashrc`, `.bash_profile`).

### Usage

nvm:
> $ nvm <kbd>Tab</kbd>
```
alias               deactivate          install             ls                  run                 unload
clear-cache         exec                list                ls-remote           unalias             use
current             help                list-remote         reinstall-packages  uninstall           version
```

nvm alias:
> $ nvm alias <kbd>Tab</kbd>
```
default
```

> $ nvm alias my_alias <kbd>Tab</kbd>
```
v0.6.21        v0.8.26       v0.10.28
```

nvm use:
> $ nvm use <kbd>Tab</kbd>
```
my_alias        default        v0.6.21        v0.8.26       v0.10.28
```

nvm uninstall:
> $ nvm uninstall <kbd>Tab</kbd>
```
my_alias        default        v0.6.21        v0.8.26       v0.10.28
```

## Compatibility Issues
`nvm` will encounter some issues if you have some non-default settings set. (see [#606](/../../issues/606))
The following are known to cause issues:

Inside `~/.npmrc`:
```sh
prefix='some/path'
```
Environment Variables:
```sh
$NPM_CONFIG_PREFIX
$PREFIX
```
Shell settings:
```sh
set -e
```

## Installing nvm on Alpine Linux
In order to provide the best performance (and other optimisations), nvm will download and install pre-compiled binaries for Node (and npm) when you run `nvm install X`. The Node project compiles, tests and hosts/provides pre-these compiled binaries which are built for mainstream/traditional Linux distributions (such as Debian, Ubuntu, CentOS, RedHat et al).

Alpine Linux, unlike mainstream/traditional Linux distributions, is based on [busybox](https://www.busybox.net/), a very compact (~5MB) Linux distribution. Busybox (and thus Alpine Linux) uses a different C/C++ stack to most mainstream/traditional Linux distributions - [musl](https://www.musl-libc.org/). This makes binary programs built for such mainstream/traditional incompatible with Alpine Linux, thus we cannot simply `nvm install X` on Alpine Linux and expect the downloaded binary to run correctly - you'll likely see "...does not exist" errors if you try that.

There is a `-s` flag for `nvm install` which requests nvm download Node source and compile it locally.

If installing nvm on Alpine Linux *is* still what you want or need to do, you should be able to achieve this by running the following from you Alpine Linux shell:

```sh
apk add -U curl bash ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
```

The Node project has some desire but no concrete plans (due to the overheads of building, testing and support) to offer Alpine-compatible binaries.

As a potential alternative, @mhart (a Node contributor) has some [Docker images for Alpine Linux with Node and optionally, npm, pre-installed](https://github.com/mhart/alpine-node).

## Docker for development environment

To make the development and testing work easier, we have a Dockerfile for development usage, which is based on Ubuntu 14.04 base image, prepared with essential and useful tools for `nvm` development, to build the docker image of the environment, run the docker command at the root of `nvm` repository:

```sh
$ docker build -t nvm-dev .
```

This will package your current nvm repository with our pre-defiend development environment into a docker image named `nvm-dev`, once it's built with success, validate your image via `docker images`:

```sh
$ docker images

REPOSITORY         TAG                 IMAGE ID            CREATED             SIZE
nvm-dev            latest              9ca4c57a97d8        7 days ago          1.22 GB
```

If you got no error message, now you can easily involve in:

```sh
$ docker run -it nvm-dev -h nvm-dev

nvm@nvm-dev:~/.nvm$
```

Please note that it'll take about 15 minutes to build the image and the image size would be about 1.2GB, so it's not suitable for production usage.

For more information and documentation about docker, please refer to its official website:
 - https://www.docker.com/
 - https://docs.docker.com/

## Problems

 - If you try to install a node version and the installation fails, be sure to delete the node downloads from src (`~/.nvm/src/`) or you might get an error when trying to reinstall them again or you might get an error like the following:

    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.

 - Where's my `sudo node`? Check out [#43](https://github.com/creationix/nvm/issues/43)

 - After the v0.8.6 release of node, nvm tries to install from binary packages. But in some systems, the official binary packages don't work due to incompatibility of shared libs. In such cases, use `-s` option to force install from source:

```sh
nvm install -s 0.8.6
```

 - If setting the `default` alias does not establish the node version in new shells (i.e. `nvm current` yields `system`), ensure that the system's node `PATH` is set before the `nvm.sh` source line in your shell profile (see [#658](https://github.com/creationix/nvm/issues/658))

## Mac OS "troubleshooting"

**nvm node version not found in vim shell**

If you set node version to a version other than your system node version `nvm use 6.2.1` and open vim and run `:!node -v` you should see `v6.2.1` if you see your system version `v0.12.7`. You need to run:

```shell
sudo chmod ugo-x /usr/libexec/path_helper
```

More on this issue in [dotphiles/dotzsh](https://github.com/dotphiles/dotzsh#mac-os-x).

[1]: https://github.com/creationix/nvm.git
[2]: https://github.com/creationix/nvm/blob/v0.33.6/install.sh
[3]: https://travis-ci.org/creationix/nvm
[4]: https://github.com/creationix/nvm/releases/tag/v0.33.6
[Urchin]: https://github.com/scraperwiki/urchin
[Fish]: http://fishshell.com
