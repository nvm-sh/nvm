<a href="https://github.com/nvm-sh/logos">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-white.svg" />
    <img src="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-color.svg" height="50" alt="nvm project logo" />
  </picture>
</a>


# Node Version Manager [![Tests](https://github.com/nvm-sh/nvm/actions/workflows/tests-fast.yml/badge.svg?branch=master)][3] [![nvm version](https://img.shields.io/badge/version-v0.40.4-yellow.svg)[...]

<!-- To update this table of contents, ensure you have run `npm install` then `npm run doctoc` -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctOC TO UPDATE -->
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
$ nvm use 24
Now using node v24.13.1 (npm v11.4.2)
$ node -v
v24.13.1
$ nvm use 22
Now using node v22.14.0 (npm v10.9.2)
$ node -v
v22.14.0
$ nvm install 20
Now using node v20.18.3 (npm v10.8.2)
$ node -v
v20.18.3
```

Simple as that!


## About
nvm is a version manager for [node.js](https://nodejs.org/en/), designed to be installed per-user, and invoked per-shell. `nvm` works on any POSIX-compliant shell (sh, dash, ksh, zsh, bash), in pa[...]

<a id="installation-and-update"></a>
<a id="install-script"></a>
## Installing and Updating

### Install & Update Script

To **install** or **update** nvm, you should run the [install script][2]. To do that, you may either download and run the script manually, or use the following cURL or Wget command:
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
```
```sh
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
```

Running either of the above commands downloads a script and runs it. The script clones the nvm repository to `~/.nvm`, and attempts to add the source lines from the snippet below to the correct p[...]

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

- You can instruct the installer to not edit your shell config (for example if you already get completions via a [zsh nvm plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm)) by s[...]

#### Installing in Docker

When invoking bash as a non-interactive shell, like in a Docker container, none of the regular profile files are sourced. In order to use `nvm`, `node`, and `npm` like normal, you can instead spe[...]

```Dockerfile
# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/user/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install
```

##### Installing in Docker for CICD-Jobs

More robust, works in CI/CD-Jobs. Can be run in interactive and non-interactive containers.
See https://github.com/nvm-sh/nvm/issues/3531.

```Dockerfile
FROM ubuntu:latest
ARG NODE_VERSION=22

# install curl
RUN apt update && apt install curl -y

# install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# set env
ENV NVM_DIR=/root/.nvm

# install node
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"

# set ENTRYPOINT for reloading nvm-environment
ENTRYPOINT ["bash", "-c", "source $NVM_DIR/nvm.sh && exec \"$@\"", "--"]

# set cmd to bash
CMD ["/bin/bash"]

```

This example defaults to installation of nodejs version 22.x.y. Optionally you can easily override the version with docker build args like:
```
docker build -t nvmimage --build-arg NODE_VERSION=24 .
```

After creation of the image you can start container interactively and run commands, for example:
```
docker run --rm -it nvmimage

root@0a6b5a237c14:/# nvm -v
0.40.4

root@0a6b5a237c14:/# node -v
v24.13.1

root@0a6b5a237c14:/# npm -v
11.4.2
```

Noninteractive example:
```
user@host:/tmp/test $ docker run --rm -it nvmimage node -v
v24.13.1
user@host:/tmp/test $ docker run --rm -it nvmimage npm -v
11.4.2
```

#### Troubleshooting on Linux

On Linux, after running the install script, if you get `nvm: command not found` or see no feedback from your terminal after you type `command -v nvm`, simply close your current terminal, open a n[...]
