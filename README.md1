<a href="https://github.com/nvm-sh/logos">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-white.svg" />
    <img src="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-color.svg" height="50" alt="nvm project logo" />
  </picture>
</a>


# Node Version Manager [![Build Status](https://app.travis-ci.com/nvm-sh/nvm.svg?branch=master)][3] [![nvm version](https://img.shields.io/badge/version-v0.40.3-yellow.svg)][4] [![CII Best Practices](https://bestpractices.dev/projects/684/badge)](https://bestpractices.dev/projects/684)

<!-- To update this table of contents, ensure you have run `npm install` then `npm run doctoc` -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Intro](#intro)
- [About](#about)
- [Installing and Updating](#installing-and-updating)
  - [Install & Update Script](#install--update-script)
    - [Additional Notes](#additional-notes)
    - [Installing in Docker](#installing-in-docker)
      - [Installing in Docker for CICD-Jobs](#installing-in-docker-for-cicd-jobs)
    - [Troubleshooting on Linux](#troubleshooting-on-linux)
    - [Troubleshooting on macOS](#troubleshooting-on-macos)
    - [Ansible](#ansible)
  - [Verify Installation](#verify-installation)
  - [Important Notes](#important-notes)
  - [Git Install](#git-install)
  - [Manual Install](#manual-install)
  - [Manual Upgrade](#manual-upgrade)
- [Usage](#usage)
  - [Long-term Support](#long-term-support)
  - [Migrating Global Packages While Installing](#migrating-global-packages-while-installing)
  - [Default Global Packages From File While Installing](#default-global-packages-from-file-while-installing)
  - [io.js](#iojs)
  - [System Version of Node](#system-version-of-node)
  - [Listing Versions](#listing-versions)
  - [Setting Custom Colors](#setting-custom-colors)
    - [Persisting custom colors](#persisting-custom-colors)
    - [Suppressing colorized output](#suppressing-colorized-output)
  - [Restoring PATH](#restoring-path)
  - [Set default node version](#set-default-node-version)
  - [Use a mirror of node binaries](#use-a-mirror-of-node-binaries)
    - [Pass Authorization header to mirror](#pass-authorization-header-to-mirror)
  - [.nvmrc](#nvmrc)
  - [Deeper Shell Integration](#deeper-shell-integration)
    - [Calling `nvm use` automatically in a directory with a `.nvmrc` file](#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file)
      - [bash](#bash)
      - [zsh](#zsh)
      - [fish](#fish)
- [Running Tests](#running-tests)
- [Environment variables](#environment-variables)
- [Bash Completion](#bash-completion)
  - [Usage](#usage-1)
- [Compatibility Issues](#compatibility-issues)
- [Installing nvm on Alpine Linux](#installing-nvm-on-alpine-linux)
  - [Alpine Linux 3.13+](#alpine-linux-313)
  - [Alpine Linux 3.5 - 3.12](#alpine-linux-35---312)
- [Uninstalling / Removal](#uninstalling--removal)
  - [Manual Uninstall](#manual-uninstall)
- [Docker For Development Environment](#docker-for-development-environment)
- [Problems](#problems)
- [macOS Troubleshooting](#macos-troubleshooting)
- [WSL Troubleshooting](#wsl-troubleshooting)
- [Maintainers](#maintainers)
- [Project Support](#project-support)
- [Enterprise Support](#enterprise-support)
- [License](#license)
- [Copyright notice](#copyright-notice)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Intro

`nvm` allows you to quickly install and use different versions of node via the command line.

**Example:**
```sh
$ nvm use 16
Now using node v16.9.1 (npm v7.21.1)
$ node -v
v16.9.1
$ nvm use 14
Now using node v14.18.0 (npm v6.14.15)
$ node -v
v14.18.0
$ nvm install 12
Now using node v12.22.6 (npm v6.14.5)
$ node -v
v12.22.6
```

Simple as that!


## About
nvm is a version manager for [node.js](https://nodejs.org/en/), designed to be installed per-user, and invoked per-shell. `nvm` works on any POSIX-compliant shell (sh, dash, ksh, zsh, bash), in particular on these platforms: unix, macOS, and [windows WSL](https://github.com/nvm-sh/nvm#important-notes).

<a id="installation-and-update"></a>
<a id="install-script"></a>
## Installing and Updating

### Install & Update Script

To **install** or **update** nvm, you should run the [install script][2]. To do that, you may either download and run the script manually, or use the following cURL or Wget command:
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```
```sh
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

Running either of the above commands downloads a script and runs it. The script clones the nvm repository to `~/.nvm`, and attempts to add the source lines from the snippet below to the correct profile file (`~/.bashrc`, `~/.bash_profile`, `~/.zshrc`, or `~/.profile`). If you find the install script is updating the wrong profile file, set the `$PROFILE` env var to the profile file’s path, and then rerun the installation script.

<a id="profile_snippet"></a>
```sh
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

#### Additional Notes

- If the environment variable `$XDG_CONFIG_HOME` is present, it will place the `nvm` files there.</sub>

- You can add `--no-use` to the end of the above script to postpone using `nvm` until you manually [`use`](#usage) it:

```sh
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm, without auto-using the default version
```

- You can customize the install source, directory, profile, and version using the `NVM_SOURCE`, `NVM_DIR`, `PROFILE`, and `NODE_VERSION` variables.
Eg: `curl ... | NVM_DIR="path/to/nvm"`. Ensure that the `NVM_DIR` does not contain a trailing slash.

- The installer can use `git`, `curl`, or `wget` to download `nvm`, whichever is available.

- You can instruct the installer to not edit your shell config (for example if you already get completions via a [zsh nvm plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm)) by setting `PROFILE=/dev/null` before running the `install.sh` script. Here's an example one-line command to do that: `PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'`

#### Installing in Docker

When invoking bash as a non-interactive shell, like in a Docker container, none of the regular profile files are sourced. In order to use `nvm`, `node`, and `npm` like normal, you can instead specify the special `BASH_ENV` variable, which bash sources when invoked non-interactively.

```Dockerfile
# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/user/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install
```

##### Installing in Docker for CICD-Jobs

More robust, works in CI/CD-Jobs. Can be run in interactive and non-interactive containers.
See https://github.com/nvm-sh/nvm/issues/3531.

```Dockerfile
FROM ubuntu:latest
ARG NODE_VERSION=20

# install curl
RUN apt update && apt install curl -y

# install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# set env
ENV NVM_DIR=/root/.nvm

# install node
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"

# set ENTRYPOINT for reloading nvm-environment
ENTRYPOINT ["bash", "-c", "source $NVM_DIR/nvm.sh && exec \"$@\"", "--"]

# set cmd to bash
CMD ["/bin/bash"]

```

This example defaults to installation of nodejs version 20.x.y. Optionally you can easily override the version with docker build args like:
```
docker build -t nvmimage --build-arg NODE_VERSION=19 .
```

After creation of the image you can start container interactively and run commands, for example:
```
docker run --rm -it nvmimage

root@0a6b5a237c14:/# nvm -v
0.40.3

root@0a6b5a237c14:/# node -v
v19.9.0

root@0a6b5a237c14:/# npm -v
9.6.3
```

Noninteractive example:
```
user@host:/tmp/test $ docker run --rm -it nvmimage node -v
v19.9.0
user@host:/tmp/test $ docker run --rm -it nvmimage npm -v
9.6.3
```

#### Troubleshooting on Linux

On Linux, after running the install script, if you get `nvm: command not found` or see no feedback from your terminal after you type `command -v nvm`, simply close your current terminal, open a new terminal, and try verifying again.
Alternatively, you can run the following commands for the different shells on the command line:

*bash*: `source ~/.bashrc`

*zsh*: `source ~/.zshrc`

*ksh*: `. ~/.profile`

These should pick up the `nvm` command.

#### Troubleshooting on macOS

Since OS X 10.9, `/usr/bin/git` has been preset by Xcode command line tools, which means we can't properly detect if Git is installed or not. You need to manually install the Xcode command line tools before running the install script, otherwise, it'll fail. (see [#1782](https://github.com/nvm-sh/nvm/issues/1782))

If you get `nvm: command not found` after running the install script, one of the following might be the reason:

  - Since macOS 10.15, the default shell is `zsh` and nvm will look for `.zshrc` to update, none is installed by default. Create one with `touch ~/.zshrc` and run the install script again.

  - If you use bash, the previous default shell, your system may not have `.bash_profile` or `.bashrc` files where the command is set up. Create one of them with `touch ~/.bash_profile` or `touch ~/.bashrc` and run the install script again. Then, run `. ~/.bash_profile` or `. ~/.bashrc` to pick up the `nvm` command.

  - You have previously used `bash`, but you have `zsh` installed. You need to manually add [these lines](#manual-install) to `~/.zshrc` and run `. ~/.zshrc`.

  - You might need to restart your terminal instance or run `. ~/.nvm/nvm.sh`. Restarting your terminal/opening a new tab/window, or running the source command will load the command and the new configuration.

  - If the above didn't help, you might need to restart your terminal instance. Try opening a new tab/window in your terminal and retry.

If the above doesn't fix the problem, you may try the following:

  - If you use bash, it may be that your `.bash_profile` (or `~/.profile`) does not source your `~/.bashrc` properly. You could fix this by adding `source ~/<your_profile_file>` to it or following the next step below.

  - Try adding [the snippet from the install section](#profile_snippet), that finds the correct nvm directory and loads nvm, to your usual profile (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`).

  - For more information about this issue and possible workarounds, please [refer here](https://github.com/nvm-sh/nvm/issues/576)

**Note** For Macs with the Apple Silicon chip, node started offering **arm64** arch Darwin packages since v16.0.0 and experimental **arm64** support when compiling from source since v14.17.0. If you are facing issues installing node using `nvm`, you may want to update to one of those versions or later.

#### Ansible

You can use a task:

```yaml
- name: Install nvm
  ansible.builtin.shell: >
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  args:
    creates: "{{ ansible_env.HOME }}/.nvm/nvm.sh"
```

### Verify Installation

To verify that nvm has been installed, do:

```sh
command -v nvm
```

which should output `nvm` if the installation was successful. Please note that `which nvm` will not work, since `nvm` is a sourced shell function, not an executable binary.

**Note:** On Linux, after running the install script, if you get `nvm: command not found` or see no feedback from your terminal after you type `command -v nvm`, simply close your current terminal, open a new terminal, and try verifying again.

### Important Notes

If you're running a system without prepackaged binary available, which means you're going to install node or io.js from its source code, you need to make sure your system has a C++ compiler. For OS X, Xcode will work, for Debian/Ubuntu based GNU/Linux, the `build-essential` and `libssl-dev` packages work.

**Note:** `nvm` also supports Windows in some cases. It should work through WSL (Windows Subsystem for Linux) depending on the version of WSL. It should also work with [GitBash](https://gitforwindows.org/) (MSYS) or [Cygwin](https://cygwin.com). Otherwise, for Windows, a few alternatives exist, which are neither supported nor developed by us:

  - [nvm-windows](https://github.com/coreybutler/nvm-windows)
  - [nodist](https://github.com/marcelklehr/nodist)
  - [nvs](https://github.com/jasongin/nvs)

**Note:** `nvm` does not support [Fish] either (see [#303](https://github.com/nvm-sh/nvm/issues/303)). Alternatives exist, which are neither supported nor developed by us:

  - [bass](https://github.com/edc/bass) allows you to use utilities written for Bash in fish shell
  - [fast-nvm-fish](https://github.com/brigand/fast-nvm-fish) only works with version numbers (not aliases) but doesn't significantly slow your shell startup
  - [plugin-nvm](https://github.com/derekstavis/plugin-nvm) plugin for [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish), which makes nvm and its completions available in fish shell
  - [nvm.fish](https://github.com/jorgebucaran/nvm.fish) - The Node.js version manager you'll adore, crafted just for Fish
  - [fish-nvm](https://github.com/FabioAntunes/fish-nvm) - Wrapper around nvm for fish, delays sourcing nvm until it's actually used.

**Note:** We still have some problems with FreeBSD, because there is no official pre-built binary for FreeBSD, and building from source may need [patches](https://www.freshports.org/www/node/files/patch-deps_v8_src_base_platform_platform-posix.cc); see the issue ticket:

  - [[#900] [Bug] node on FreeBSD may need to be patched](https://github.com/nvm-sh/nvm/issues/900)
  - [nodejs/node#3716](https://github.com/nodejs/node/issues/3716)

**Note:** On OS X, if you do not have Xcode installed and you do not wish to download the ~4.3GB file, you can install the `Command Line Tools`. You can check out this blog post on how to just that:

  - [How to Install Command Line Tools in OS X Mavericks & Yosemite (Without Xcode)](https://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/)

**Note:** On OS X, if you have/had a "system" node installed and want to install modules globally, keep in mind that:

  - When using `nvm` you do not need `sudo` to globally install a module with `npm -g`, so instead of doing `sudo npm install -g grunt`, do instead `npm install -g grunt`
  - If you have an `~/.npmrc` file, make sure it does not contain any `prefix` settings (which is not compatible with `nvm`)
  - You can (but should not?) keep your previous "system" node install, but `nvm` will only be available to your user account (the one used to install nvm). This might cause version mismatches, as other users will be using `/usr/local/lib/node_modules/*` VS your user account using `~/.nvm/versions/node/vX.X.X/lib/node_modules/*`

Homebrew installation is not supported. If you have issues with homebrew-installed `nvm`, please `brew uninstall` it, and install it using the instructions below, before filing an issue.

**Note:** If you're using `zsh` you can easily install `nvm` as a zsh plugin. Install [`zsh-nvm`](https://github.com/lukechilds/zsh-nvm) and run `nvm upgrade` to upgrade ([you can set](https://github.com/lukechilds/zsh-nvm#auto-use) `NVM_AUTO_USE=true` to have it automatically detect and use `.nvmrc` files).

**Note:** Git versions before v1.7 may face a problem of cloning `nvm` source from GitHub via https protocol, and there is also different behavior of git before v1.6, and git prior to [v1.17.10](https://github.com/git/git/commit/5a7d5b683f869d3e3884a89775241afa515da9e7) can not clone tags, so the minimum required git version is v1.7.10. If you are interested in the problem we mentioned here, please refer to GitHub's [HTTPS cloning errors](https://help.github.com/articles/https-cloning-errors/) article.

### Git Install

If you have `git` installed (requires git v1.7.10+):

1. clone this repo in the root of your user profile
    - `cd ~/` from anywhere then `git clone https://github.com/nvm-sh/nvm.git .nvm`
1. `cd ~/.nvm` and check out the latest version with `git checkout v0.40.3`
1. activate `nvm` by sourcing it from your shell: `. ./nvm.sh`

Now add these lines to your `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login:
(you may have to add to more than one of the above files)

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

### Manual Install

For a fully manual install, execute the following lines to first clone the `nvm` repository into `$HOME/.nvm`, and then load `nvm`:

```sh
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"
```

Now add these lines to your `~/.bashrc`, `~/.profile`, or `~/.zshrc` file to have it automatically sourced upon login:
(you may have to add to more than one of the above files)

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

### Manual Upgrade

For manual upgrade with `git` (requires git v1.7.10+):

1. change to the `$NVM_DIR`
1. pull down the latest changes
1. check out the latest version
1. activate the new version

```sh
(
  cd "$NVM_DIR"
  git fetch --tags origin
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"
```

## Usage

To download, compile, and install the latest release of node, do this:

```sh
nvm install node # "node" is an alias for the latest version
```

To install a specific version of node:

```sh
nvm install 14.7.0 # or 16.3.0, 12.22.1, etc
```

To set an alias:

```sh
nvm alias my_alias v14.4.0
```
Make sure that your alias does not contain any spaces or slashes.

The first version installed becomes the default. New shells will start with the default version of node (e.g., `nvm alias default`).

You can list available versions using `ls-remote`:

```sh
nvm ls-remote
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
nvm which 12.22
```

In place of a version pointer like "14.7" or "16.3" or "12.22.1", you can use the following special default aliases with `nvm install`, `nvm use`, `nvm run`, `nvm exec`, `nvm which`, etc:

  - `node`: this installs the latest version of [`node`](https://nodejs.org/en/)
  - `iojs`: this installs the latest version of [`io.js`](https://iojs.org/en/)
  - `stable`: this alias is deprecated, and only truly applies to `node` `v0.12` and earlier. Currently, this is an alias for `node`.
  - `unstable`: this alias points to `node` `v0.11` - the last "unstable" node release, since post-1.0, all node versions are stable. (in SemVer, versions communicate breakage, not stability).

### Long-term Support

Node has a [schedule](https://github.com/nodejs/Release#release-schedule) for long-term support (LTS) You can reference LTS versions in aliases and `.nvmrc` files with the notation `lts/*` for the latest LTS, and `lts/argon` for LTS releases from the "argon" line, for example. In addition, the following commands support LTS arguments:

  - `nvm install --lts` / `nvm install --lts=argon` / `nvm install 'lts/*'` / `nvm install lts/argon`
  - `nvm uninstall --lts` / `nvm uninstall --lts=argon` / `nvm uninstall 'lts/*'` / `nvm uninstall lts/argon`
  - `nvm use --lts` / `nvm use --lts=argon` / `nvm use 'lts/*'` / `nvm use lts/argon`
  - `nvm exec --lts` / `nvm exec --lts=argon` / `nvm exec 'lts/*'` / `nvm exec lts/argon`
  - `nvm run --lts` / `nvm run --lts=argon` / `nvm run 'lts/*'` / `nvm run lts/argon`
  - `nvm ls-remote --lts` / `nvm ls-remote --lts=argon` `nvm ls-remote 'lts/*'` / `nvm ls-remote lts/argon`
  - `nvm version-remote --lts` / `nvm version-remote --lts=argon` / `nvm version-remote 'lts/*'` / `nvm version-remote lts/argon`

Any time your local copy of `nvm` connects to https://nodejs.org, it will re-create the appropriate local aliases for all available LTS lines. These aliases (stored under `$NVM_DIR/alias/lts`), are managed by `nvm`, and you should not modify, remove, or create these files - expect your changes to be undone, and expect meddling with these files to cause bugs that will likely not be supported.

To get the latest LTS version of node and migrate your existing installed packages, use

```sh
nvm install --reinstall-packages-from=current 'lts/*'
```

### Migrating Global Packages While Installing

If you want to install a new version of Node.js and migrate npm packages from a previous version:

```sh
nvm install --reinstall-packages-from=node node
```

This will first use "nvm version node" to identify the current version you're migrating packages from. Then it resolves the new version to install from the remote server and installs it. Lastly, it runs "nvm reinstall-packages" to reinstall the npm packages from your prior version of Node to the new one.

You can also install and migrate npm packages from specific versions of Node like this:

```sh
nvm install --reinstall-packages-from=5 6
nvm install --reinstall-packages-from=iojs v4.2
```

Note that reinstalling packages _explicitly does not update the npm version_ — this is to ensure that npm isn't accidentally upgraded to a broken version for the new node version.

To update npm at the same time add the `--latest-npm` flag, like this:

```sh
nvm install --reinstall-packages-from=default --latest-npm 'lts/*'
```

or, you can at any time run the following command to get the latest supported npm version on the current node version:
```sh
nvm install-latest-npm
```

If you've already gotten an error to the effect of "npm does not support Node.js", you'll need to (1) revert to a previous node version (`nvm ls` & `nvm use <your latest _working_ version from the ls>`), (2) delete the newly created node version (`nvm uninstall <your _broken_ version of node from the ls>`), then (3) rerun your `nvm install` with the `--latest-npm` flag.


### Default Global Packages From File While Installing

If you have a list of default packages you want installed every time you install a new version, we support that too -- just add the package names, one per line, to the file `$NVM_DIR/default-packages`. You can add anything npm would accept as a package argument on the command line.

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
nvm install --reinstall-packages-from=iojs iojs
```

The same guidelines mentioned for migrating npm packages in node are applicable to io.js.

### System Version of Node

If you want to use the system-installed version of node, you can use the special default alias "system":

```sh
nvm use system
nvm run system --version
```

### Listing Versions

If you want to see what versions are installed:

```sh
nvm ls
```

If you want to see what versions are available to install:

```sh
nvm ls-remote
```

### Setting Custom Colors

You can set five colors that will be used to display version and alias information. These colors replace the default colors.
  Initial colors are: g b y r e

  Color codes:

    r/R = red / bold red

    g/G = green / bold green

    b/B = blue / bold blue

    c/C = cyan / bold cyan

    m/M = magenta / bold magenta

    y/Y = yellow / bold yellow

    k/K = black / bold black

    e/W = light grey / white

```sh
nvm set-colors rgBcm
```

#### Persisting custom colors

If you want the custom colors to persist after terminating the shell, export the `NVM_COLORS` variable in your shell profile. For example, if you want to use cyan, magenta, green, bold red and bold yellow, add the following line:

```sh
export NVM_COLORS='cmgRY'
```

#### Suppressing colorized output

`nvm help (or -h or --help)`, `nvm ls`, `nvm ls-remote` and `nvm alias` usually produce colorized output. You can disable colors with the `--no-colors` option (or by setting the environment variable `TERM=dumb`):

```sh
nvm ls --no-colors
nvm help --no-colors
TERM=dumb nvm ls
```

### Restoring PATH
To restore your PATH, you can deactivate it:

```sh
nvm deactivate
```

### Set default node version
To set a default Node version to be used in any new shell, use the alias 'default':

```sh
nvm alias default node # this refers to the latest installed version of node
nvm alias default 18 # this refers to the latest installed v18.x version of node
nvm alias default 18.12  # this refers to the latest installed v18.12.x version of node
```

### Use a mirror of node binaries
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

#### Pass Authorization header to mirror
To pass an Authorization header through to the mirror url, set `$NVM_AUTH_HEADER`

```sh
NVM_AUTH_HEADER="Bearer secret-token" nvm install node
```

### .nvmrc

You can create a `.nvmrc` file containing a node version number (or any other string that `nvm` understands; see `nvm --help` for details) in the project root directory (or any parent directory).
Afterwards, `nvm use`, `nvm install`, `nvm exec`, `nvm run`, and `nvm which` will use the version specified in the `.nvmrc` file if no version is supplied on the command line.

For example, to make nvm default to the latest 5.9 release, the latest LTS version, or the latest node version for the current directory:

```sh
$ echo "5.9" > .nvmrc

$ echo "lts/*" > .nvmrc # to default to the latest LTS version

$ echo "node" > .nvmrc # to default to the latest version
```

[NB these examples assume a POSIX-compliant shell version of `echo`. If you use a Windows `cmd` development environment, eg the `.nvmrc` file is used to configure a remote Linux deployment, then keep in mind the `"`s will be copied leading to an invalid file. Remove them.]

Then when you run nvm use:

```sh
$ nvm use
Found '/path/to/project/.nvmrc' with version <5.9>
Now using node v5.9.1 (npm v3.7.3)
```

Running nvm install will also switch over to the correct version, but if the correct node version isn't already installed, it will install it for you.

```sh
$ nvm install
Found '/path/to/project/.nvmrc' with version <5.9>
Downloading and installing node v5.9.1...
Downloading https://nodejs.org/dist/v5.9.1/node-v5.9.1-linux-x64.tar.xz...
#################################################################################### 100.0%
Computing checksum with sha256sum
Checksums matched!
Now using node v5.9.1 (npm v3.7.3)
```

`nvm use` et. al. will traverse directory structure upwards from the current directory looking for the `.nvmrc` file. In other words, running `nvm use` et. al. in any subdirectory of a directory with an `.nvmrc` will result in that `.nvmrc` being utilized.

The contents of a `.nvmrc` file **must** contain precisely one `<version>` (as described by `nvm --help`) followed by a newline. `.nvmrc` files may also have comments. The comment delimiter is `#`, and it and any text after it, as well as blank lines, and leading and trailing white space, will be ignored when parsing.

Key/value pairs using `=` are also allowed and ignored, but are reserved for future use, and may cause validation errors in the future.

Run [`npx nvmrc`](https://npmjs.com/nvmrc) to validate an `.nvmrc` file. If that tool’s results do not agree with nvm, one or the other has a bug - please file an issue.

### Deeper Shell Integration

You can use [`nvshim`](https://github.com/iamogbz/nvshim) to shim the `node`, `npm`, and `npx` bins to automatically use the `nvm` config in the current directory. `nvshim` is **not** supported by the `nvm` maintainers. Please [report issues to the `nvshim` team](https://github.com/iamogbz/nvshim/issues/new).

If you prefer a lighter-weight solution, the recipes below have been contributed by `nvm` users. They are **not** supported by the `nvm` maintainers. We are, however, accepting pull requests for more examples.

#### Calling `nvm use` automatically in a directory with a `.nvmrc` file

In your profile (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`), add the following to `nvm use` whenever you enter a new directory:

##### bash

Put the following at the end of your `$HOME/.bashrc`:

```bash
cdnvm() {
    command cd "$@" || return $?
    nvm_path="$(nvm_find_up .nvmrc | command tr -d '\n')"

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version
        default_version="$(nvm version default)"

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [ $default_version = 'N/A' ]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [ "$(nvm current)" != "${default_version}" ]; then
            nvm use default
        fi
    elif [[ -s "${nvm_path}/.nvmrc" && -r "${nvm_path}/.nvmrc" ]]; then
        declare nvm_version
        nvm_version=$(<"${nvm_path}"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "${nvm_version}" | command tail -1 | command tr -d '\->*' | command tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [ "${locally_resolved_nvm_version}" = 'N/A' ]; then
            nvm install "${nvm_version}";
        elif [ "$(nvm current)" != "${locally_resolved_nvm_version}" ]; then
            nvm use "${nvm_version}";
        fi
    fi
}

alias cd='cdnvm'
cdnvm "$PWD" || exit
```

This alias would search 'up' from your current directory in order to detect a `.nvmrc` file. If it finds it, it will switch to that version; if not, it will use the default version.

##### zsh

This shell function will install (if needed) and `nvm use` the specified Node version when an `.nvmrc` is found, and `nvm use default` otherwise.

Put this into your `$HOME/.zshrc` to call `nvm use` automatically whenever you enter a directory that contains an
`.nvmrc` file with a string telling nvm which node to `use`:

```zsh
# place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

After saving the file, run `source ~/.zshrc` to reload the configuration with the latest changes made.

##### fish

This requires that you have [bass](https://github.com/edc/bass) installed.
```fish
# ~/.config/fish/functions/nvm.fish
function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

# ~/.config/fish/functions/nvm_find_nvmrc.fish
function nvm_find_nvmrc
  bass source ~/.nvm/nvm.sh --no-use ';' nvm_find_nvmrc
end

# ~/.config/fish/functions/load_nvm.fish
function load_nvm --on-variable="PWD"
  set -l default_node_version (nvm version default)
  set -l node_version (nvm version)
  set -l nvmrc_path (nvm_find_nvmrc)
  if test -n "$nvmrc_path"
    set -l nvmrc_node_version (nvm version (cat $nvmrc_path))
    if test "$nvmrc_node_version" = "N/A"
      nvm install (cat $nvmrc_path)
    else if test "$nvmrc_node_version" != "$node_version"
      nvm use $nvmrc_node_version
    end
  else if test "$node_version" != "$default_node_version"
    echo "Reverting to default Node version"
    nvm use default
  end
end

# ~/.config/fish/config.fish
# You must call it on initialization or listening to directory switching won't work
load_nvm > /dev/stderr
```

## Running Tests

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

## Environment variables

nvm exposes the following environment variables:

- `NVM_DIR` - nvm's installation directory.
- `NVM_BIN` - where node, npm, and global packages for the active version of node are installed.
- `NVM_INC` - node's include file directory (useful for building C/C++ addons for node).
- `NVM_CD_FLAGS` - used to maintain compatibility with zsh.
- `NVM_RC_VERSION` - version from .nvmrc file if being used.

Additionally, nvm modifies `PATH`, and, if present, `MANPATH` and `NODE_PATH` when changing versions.


## Bash Completion

To activate, you need to source `bash_completion`:

```sh
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
```

Put the above sourcing line just below the sourcing line for nvm in your profile (`.bashrc`, `.bash_profile`).

### Usage

nvm:

> `$ nvm` <kbd>Tab</kbd>
```sh
alias               deactivate          install             list-remote         reinstall-packages  uninstall           version
cache               exec                install-latest-npm  ls                  run                 unload              version-remote
current             help                list                ls-remote           unalias             use                 which
```

nvm alias:

> `$ nvm alias` <kbd>Tab</kbd>
```sh
default      iojs         lts/*        lts/argon    lts/boron    lts/carbon   lts/dubnium  lts/erbium   node         stable       unstable
```


> `$ nvm alias my_alias` <kbd>Tab</kbd>
```sh
v10.22.0       v12.18.3      v14.8.0
```

nvm use:
> `$ nvm use` <kbd>Tab</kbd>

```
my_alias        default        v10.22.0       v12.18.3      v14.8.0
```

nvm uninstall:
> `$ nvm uninstall` <kbd>Tab</kbd>

```
my_alias        default        v10.22.0       v12.18.3      v14.8.0
```

## Compatibility Issues

`nvm` will encounter some issues if you have some non-default settings set. (see [#606](https://github.com/nvm-sh/nvm/issues/606))
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

In order to provide the best performance (and other optimizations), nvm will download and install pre-compiled binaries for Node (and npm) when you run `nvm install X`. The Node project compiles, tests and hosts/provides these pre-compiled binaries which are built for mainstream/traditional Linux distributions (such as Debian, Ubuntu, CentOS, RedHat et al).

Alpine Linux, unlike mainstream/traditional Linux distributions, is based on [BusyBox](https://www.busybox.net/), a very compact (~5MB) Linux distribution. BusyBox (and thus Alpine Linux) uses a different C/C++ stack to most mainstream/traditional Linux distributions - [musl](https://www.musl-libc.org/). This makes binary programs built for such mainstream/traditional incompatible with Alpine Linux, thus we cannot simply `nvm install X` on Alpine Linux and expect the downloaded binary to run correctly - you'll likely see "...does not exist" errors if you try that.

There is a `-s` flag for `nvm install` which requests nvm download Node source and compile it locally.

If installing nvm on Alpine Linux *is* still what you want or need to do, you should be able to achieve this by running the following from you Alpine Linux shell, depending on which version you are using:

### Alpine Linux 3.13+
```sh
apk add -U curl bash ca-certificates openssl ncurses coreutils python3 make gcc g++ libgcc linux-headers grep util-linux binutils findutils
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

### Alpine Linux 3.5 - 3.12
```sh
apk add -U curl bash ca-certificates openssl ncurses coreutils python2 make gcc g++ libgcc linux-headers grep util-linux binutils findutils
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

_Note: Alpine 3.5 can only install NodeJS versions up to v6.9.5, Alpine 3.6 can only install versions up to v6.10.3, Alpine 3.7 installs versions up to v8.9.3, Alpine 3.8 installs versions up to v8.14.0, Alpine 3.9 installs versions up to v10.19.0, Alpine 3.10 installs versions up to v10.24.1, Alpine 3.11 installs versions up to v12.22.6, Alpine 3.12 installs versions up to v12.22.12, Alpine 3.13 & 3.14 install versions up to v14.20.0, Alpine 3.15 & 3.16 install versions up to v16.16.0 (**These are all versions on the main branch**). Alpine 3.5 - 3.12 required the package `python2` to build NodeJS, as they are older versions to build. Alpine 3.13+ requires `python3` to successfully build newer NodeJS versions, but you can use `python2` with Alpine 3.13+ if you need to build versions of node supported in Alpine 3.5 - 3.15, you just need to specify what version of NodeJS you need to install in the package install script._

The Node project has some desire but no concrete plans (due to the overheads of building, testing and support) to offer Alpine-compatible binaries.

As a potential alternative, @mhart (a Node contributor) has some [Docker images for Alpine Linux with Node and optionally, npm, pre-installed](https://github.com/mhart/alpine-node).

<a id="removal"></a>
## Uninstalling / Removal

### Manual Uninstall

To remove `nvm` manually, execute the following:

First, use `nvm unload` to remove the nvm command from your terminal session and delete the installation directory:

```sh
$ nvm_dir="${NVM_DIR:-~/.nvm}"
$ nvm unload
$ rm -rf "$nvm_dir"
```

Edit `~/.bashrc` (or other shell resource config) and remove the lines below:

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
```

## Docker For Development Environment

To make the development and testing work easier, we have a Dockerfile for development usage, which is based on Ubuntu 18.04 base image, prepared with essential and useful tools for `nvm` development, to build the docker image of the environment, run the docker command at the root of `nvm` repository:

```sh
$ docker build -t nvm-dev .
```

This will package your current nvm repository with our pre-defined development environment into a docker image named `nvm-dev`, once it's built with success, validate your image via `docker images`:

```sh
$ docker images

REPOSITORY         TAG                 IMAGE ID            CREATED             SIZE
nvm-dev            latest              9ca4c57a97d8        7 days ago          650 MB
```

If you got no error message, now you can easily involve in:

```sh
$ docker run -h nvm-dev -it nvm-dev

nvm@nvm-dev:~/.nvm$
```

Please note that it'll take about 8 minutes to build the image and the image size would be about 650MB, so it's not suitable for production usage.

For more information and documentation about docker, please refer to its official website:

  - https://www.docker.com/
  - https://docs.docker.com/

## Problems

  - If you try to install a node version and the installation fails, be sure to run `nvm cache clear` to delete cached node downloads, or you might get an error like the following:

    curl: (33) HTTP server doesn't seem to support byte ranges. Cannot resume.

  - Where's my `sudo node`? Check out [#43](https://github.com/nvm-sh/nvm/issues/43)

  - After the v0.8.6 release of node, nvm tries to install from binary packages. But in some systems, the official binary packages don't work due to incompatibility of shared libs. In such cases, use `-s` option to force install from source:

```sh
nvm install -s 0.8.6
```

  - If setting the `default` alias does not establish the node version in new shells (i.e. `nvm current` yields `system`), ensure that the system's node `PATH` is set before the `nvm.sh` source line in your shell profile (see [#658](https://github.com/nvm-sh/nvm/issues/658))

## macOS Troubleshooting

**nvm node version not found in vim shell**

If you set node version to a version other than your system node version `nvm use 6.2.1` and open vim and run `:!node -v` you should see `v6.2.1` if you see your system version `v0.12.7`. You need to run:

```shell
sudo chmod ugo-x /usr/libexec/path_helper
```

More on this issue in [dotphiles/dotzsh](https://github.com/dotphiles/dotzsh#mac-os-x).

**nvm is not compatible with the npm config "prefix" option**

Some solutions for this issue can be found [here](https://github.com/nvm-sh/nvm/issues/1245)

There is one more edge case causing this issue, and that's a **mismatch between the `$HOME` path and the user's home directory's actual name**.

You have to make sure that the user directory name in `$HOME` and the user directory name you'd see from running `ls /Users/` **are capitalized the same way** ([See this issue](https://github.com/nvm-sh/nvm/issues/2261)).

To change the user directory and/or account name follow the instructions [here](https://support.apple.com/en-us/HT201548)

[1]: https://github.com/nvm-sh/nvm.git
[2]: https://github.com/nvm-sh/nvm/blob/v0.40.3/install.sh
[3]: https://app.travis-ci.com/nvm-sh/nvm
[4]: https://github.com/nvm-sh/nvm/releases/tag/v0.40.3
[Urchin]: https://git.sdf.org/tlevine/urchin
[Fish]: https://fishshell.com

**Homebrew makes zsh directories unsecure**

```shell
zsh compinit: insecure directories, run compaudit for list.
Ignore insecure directories and continue [y] or abort compinit [n]? y
```

Homebrew causes insecure directories like `/usr/local/share/zsh/site-functions` and `/usr/local/share/zsh`. This is **not** an `nvm` problem - it is a homebrew problem. Refer [here](https://github.com/zsh-users/zsh-completions/issues/680) for some solutions related to the issue.

**Macs with Apple Silicon chips**

Experimental support for the Apple Silicon chip architecture was added in node.js v15.3 and full support was added in v16.0.
Because of this, if you try to install older versions of node as usual, you will probably experience either compilation errors when installing node or out-of-memory errors while running your code.

So, if you want to run a version prior to v16.0 on an Apple Silicon Mac, it may be best to compile node targeting the `x86_64` Intel architecture so that Rosetta 2 can translate the `x86_64` processor instructions to ARM-based Apple Silicon instructions.
Here's what you will need to do:

- Install Rosetta, if you haven't already done so

  ```sh
  $ softwareupdate --install-rosetta
  ```

  You might wonder, "how will my Apple Silicon Mac know to use Rosetta for a version of node compiled for an Intel chip?".
  If an executable contains only Intel instructions, macOS will automatically use Rosetta to translate the instructions.

- Open a shell that's running using Rosetta

  ```sh
  $ arch -x86_64 zsh
  ```

  Note: This same thing can also be accomplished by finding the Terminal or iTerm App in Finder, right clicking, selecting "Get Info", and then checking the box labeled "Open using Rosetta".

  Note: This terminal session is now running in `zsh`.
  If `zsh` is not the shell you typically use, `nvm` may not be `source`'d automatically like it probably is for your usual shell through your dotfiles.
  If that's the case, make sure to source `nvm`.

  ```sh
  $ source "${NVM_DIR}/nvm.sh"
  ```

- Install whatever older version of node you are interested in. Let's use 12.22.1 as an example.
  This will fetch the node source code and compile it, which will take several minutes.

  ```sh
  $ nvm install v12.22.1 --shared-zlib
  ```

  Note: You're probably curious why `--shared-zlib` is included.
  There's a bug in recent versions of Apple's system `clang` compiler.
  If one of these broken versions is installed on your system, the above step will likely still succeed even if you didn't include the `--shared-zlib` flag.
  However, later, when you attempt to `npm install` something using your old version of node.js, you will see `incorrect data check` errors.
  If you want to avoid the possible hassle of dealing with this, include that flag.
  For more details, see [this issue](https://github.com/nodejs/node/issues/39313) and [this comment](https://github.com/nodejs/node/issues/39313#issuecomment-90.40.376)

- Exit back to your native shell.

  ```sh
  $ exit
  $ arch
  arm64
  ```

  Note: If you selected the box labeled "Open using Rosetta" rather than running the CLI command in the second step, you will see `i386` here.
  Unless you have another reason to have that box selected, you can deselect it now.

- Check to make sure the architecture is correct. `x64` is the abbreviation for `x86_64`, which is what you want to see.

  ```sh
  $ node -p process.arch
  x64
  ```

Now you should be able to use node as usual.

## WSL Troubleshooting

If you've encountered this error on WSL-2:

  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload  Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:09 --:--:--     0curl: (6) Could not resolve host: raw.githubusercontent.com
  ```

It may be due to your antivirus, VPN, or other reasons.

Where you can `ping 8.8.8.8` while you can't `ping google.com`


This could simply be solved by running this in your root directory:

  ```sh
  sudo rm /etc/resolv.conf
  sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
  sudo bash -c 'echo "[network]" > /etc/wsl.conf'
  sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
  sudo chattr +i /etc/resolv.conf
  ```

This deletes your `resolv.conf` file that is automatically generated when you run WSL, creates a new file and puts `nameserver 8.8.8.8`, then creates a `wsl.conf` file and adds `[network]` and `generateResolveConf = false` to prevent auto-generation of that file.

You can check the contents of the file by running:

  ```sh
  cat /etc/resolv.conf
  ```

## Maintainers

Currently, the sole maintainer is [@ljharb](https://github.com/ljharb) - more maintainers are quite welcome, and we hope to add folks to the team over time. [Governance](./GOVERNANCE.md) will be re-evaluated as the project evolves.

## Project Support

Only the latest version (v0.40.3 at this time) is supported.

## Enterprise Support

If you are unable to update to the latest version of `nvm`, our [partners](https://openjsf.org/ecosystem-sustainability-program) provide commercial security fixes for all unsupported versions:

  - [HeroDevs Never-Ending Support](https://www.herodevs.com/support?utm_source=OpenJS&utm_medium=Link&utm_campaign=nvm_openjs)

## License

See [LICENSE.md](./LICENSE.md).

## Copyright notice

Copyright [OpenJS Foundation](https://openjsf.org) and `nvm` contributors. All rights reserved. The [OpenJS Foundation](https://openjsf.org) has registered trademarks and uses trademarks.  For a list of trademarks of the [OpenJS Foundation](https://openjsf.org), please see our [Trademark Policy](https://trademark-policy.openjsf.org/) and [Trademark List](https://trademark-list.openjsf.org/).  Trademarks and logos not indicated on the [list of OpenJS Foundation trademarks](https://trademark-list.openjsf.org) are trademarks™ or registered® trademarks of their respective holders. Use of them does not imply any affiliation with or endorsement by them.
[The OpenJS Foundation](https://openjsf.org/) | [Terms of Use](https://terms-of-use.openjsf.org/) | [Privacy Policy](https://privacy-policy.openjsf.org/) | [Bylaws](https://bylaws.openjsf.org/) | [Code of Conduct](https://code-of-conduct.openjsf.org) | [Trademark Policy](https://trademark-policy.openjsf.org/) | [Trademark List](https://trademark-list.openjsf.org/) | [Cookie Policy](https://www.linuxfoundation.org/cookies/)
