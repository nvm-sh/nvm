<a href="https://github.com/nvm-sh/logos">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-white.svg" />
    <img src="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-color.svg" height="50" alt="nvm project logo" />
  </picture>
</a>

# Node Version Manager (NVM)

[![Build Status](https://app.travis-ci.com/nvm-sh/nvm.svg?branch=master)](https://app.travis-ci.com/nvm-sh/nvm) [![nvm version](https://img.shields.io/badge/version-v0.40.2-yellow.svg)](https://github.com/nvm-sh/nvm/releases) [![CII Best Practices](https://bestpractices.dev/projects/684/badge)](https://bestpractices.dev/projects/684)

---

**Node Version Manager (NVM)** is a versatile tool that empowers developers to manage multiple Node.js versions effortlessly. With NVM, switching between Node.js versions becomes seamless, ensuring compatibility and flexibility for diverse projects.

---

## Table of Contents

- [Introduction](#introduction)
- [About NVM](#about-nvm)
- [Installation and Updates](#installation-and-updates)
  - [Install & Update Script](#install--update-script)
  - [Verify Installation](#verify-installation)
  - [Important Notes](#important-notes)
  - [Git Installation](#git-installation)
  - [Manual Installation](#manual-installation)
  - [Manual Upgrade](#manual-upgrade)
- [Usage](#usage)
  - [Long-term Support (LTS)](#long-term-support-lts)
  - [Migrating Global Packages](#migrating-global-packages)
  - [Default Global Packages](#default-global-packages)
  - [Using System Node Version](#using-system-node-version)
  - [Listing Versions](#listing-versions)
  - [Customizing Colors](#customizing-colors)
  - [Restoring PATH](#restoring-path)
  - [Setting Default Node Version](#setting-default-node-version)
  - [Using Node Binary Mirrors](#using-node-binary-mirrors)
  - [Working with .nvmrc Files](#working-with-nvmrc-files)
  - [Advanced Shell Integration](#advanced-shell-integration)
- [Running Tests](#running-tests)
- [Environment Variables](#environment-variables)
- [Bash Completion](#bash-completion)
- [Compatibility Issues](#compatibility-issues)
- [Installing on Alpine Linux](#installing-on-alpine-linux)
- [Uninstalling NVM](#uninstalling-nvm)
- [Using Docker for Development](#using-docker-for-development)
- [Troubleshooting](#troubleshooting)
  - [macOS Troubleshooting](#macos-troubleshooting)
  - [WSL Troubleshooting](#wsl-troubleshooting)
- [Maintainers](#maintainers)
- [Project Support](#project-support)
- [Enterprise Support](#enterprise-support)
- [License](#license)
- [Copyright Notice](#copyright-notice)

---

## Introduction

NVM simplifies the process of managing Node.js versions, making it an indispensable tool for developers working on varied projects. With just a few commands, you can install, switch, and manage Node.js versions effortlessly.

**Example Usage:**

```sh
nvm use 16
# Now using node v16.9.1 (npm v7.21.1)
node -v
# v16.9.1
nvm use 14
# Now using node v14.18.0 (npm v6.14.15)
node -v
# v14.18.0
nvm install 12
# Now using node v12.22.6 (npm v6.14.5)
node -v
# v12.22.6
```

---

## About NVM

NVM is a version manager for [Node.js](https://nodejs.org/en/), designed to be installed per-user and invoked per-shell. It works on any POSIX-compliant shell (sh, dash, ksh, zsh, bash) and supports platforms like Unix, macOS, and [Windows WSL](https://github.com/nvm-sh/nvm#important-notes).

---

## Installation and Updates

### Install & Update Script

To **install** or **update** NVM, run the following script using either `curl` or `wget`:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
```

```sh
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
```

This script clones the NVM repository to `~/.nvm` and updates your shell profile to load NVM automatically. If the script updates the wrong profile file, set the `$PROFILE` environment variable to the correct file path and rerun the script.

---

For more details, refer to the [full documentation](#table-of-contents).

---
