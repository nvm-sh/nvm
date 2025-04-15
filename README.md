<a href="https://github.com/nvm-sh/logos">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-white.svg" />
    <img src="https://raw.githubusercontent.com/nvm-sh/logos/HEAD/nvm-logo-color.svg" height="50" alt="nvm project logo" />
  </picture>
</a>

# Node Version Manager (NVM)

[![Build Status](https://app.travis-ci.com/nvm-sh/nvm.svg?branch=master)](https://app.travis-ci.com/nvm-sh/nvm) [![nvm version](https://img.shields.io/badge/version-v0.40.2-yellow.svg)](https://github.com/nvm-sh/nvm/releases) [![CII Best Practices](https://bestpractices.dev/projects/684/badge)](https://bestpractices.dev/projects/684)

---

**Node Version Manager (NVM)** is not just a tool; it's a game-changer for developers who demand precision, flexibility, and efficiency in managing Node.js environments. Whether you're working on legacy systems or cutting-edge applications, NVM ensures your development workflow is seamless and future-proof.

---

## Table of Contents

- [Introduction](#introduction)
- [Why Choose NVM?](#why-choose-nvm)
- [Installation and Updates](#installation-and-updates)
  - [Quick Install](#quick-install)
  - [Advanced Installation](#advanced-installation)
  - [Verifying Installation](#verifying-installation)
- [Core Features](#core-features)
  - [Effortless Version Switching](#effortless-version-switching)
  - [Global Package Migration](#global-package-migration)
  - [Customizing Your Environment](#customizing-your-environment)
  - [Working with `.nvmrc` Files](#working-with-nvmrc-files)
- [Pro Tips for Power Users](#pro-tips-for-power-users)
  - [Optimizing Shell Performance](#optimizing-shell-performance)
  - [Using NVM in CI/CD Pipelines](#using-nvm-in-cicd-pipelines)
  - [Leveraging Node Binary Mirrors](#leveraging-node-binary-mirrors)
- [Troubleshooting](#troubleshooting)
  - [Common Issues and Fixes](#common-issues-and-fixes)
  - [macOS-Specific Tips](#macos-specific-tips)
- [Community and Support](#community-and-support)
- [License](#license)

---

## Introduction

In the fast-paced world of software development, managing multiple Node.js versions is no longer optional—it's essential. NVM empowers developers to:

- Seamlessly switch between Node.js versions.
- Maintain compatibility across diverse projects.
- Optimize workflows with minimal overhead.

Whether you're a solo developer or part of a large team, NVM is your go-to solution for Node.js version management.

---

## Why Choose NVM?

1. **Unparalleled Flexibility**: Switch between Node.js versions with a single command.
2. **Developer-Centric Design**: Tailored for developers, by developers.
3. **Cross-Platform Excellence**: Works flawlessly on Unix, macOS, and Windows WSL.
4. **Future-Ready**: Regular updates and a thriving community ensure NVM stays ahead of the curve.

---

## Installation and Updates

### Quick Install

For a hassle-free installation, use the following script:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
```

Or, if you prefer `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
```

### Advanced Installation

For power users who need more control, clone the repository manually:

```sh
git clone https://github.com/nvm-sh/nvm.git ~/.nvm
cd ~/.nvm
git checkout v0.40.2
```

Then, add the following to your shell profile:

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"
```

### Verifying Installation

Ensure NVM is installed correctly:

```sh
command -v nvm
```

If the output is `nvm`, you're good to go!

---

## Core Features

### Effortless Version Switching

Switching Node.js versions is as simple as:

```sh
nvm use 18
# Now using node v18.0.0
```

Want to install and use a specific version? No problem:

```sh
nvm install 16
# Now using node v16.14.0
```

### Global Package Migration

Preserve your global packages when switching Node.js versions:

```sh
nvm install 14 --reinstall-packages-from=12
```

### Customizing Your Environment

Tailor NVM to your workflow by setting environment variables like `NVM_COLORS` and `NVM_DIR`. For example:

```sh
export NVM_COLORS="bg=blue;fg=white"
```

### Working with `.nvmrc` Files

Standardize Node.js versions across your team by using `.nvmrc` files:

```sh
echo "16" > .nvmrc
nvm use
```

---

## Pro Tips for Power Users

### Optimizing Shell Performance

Speed up your shell startup by lazy-loading NVM. Add this snippet to your profile:

```sh
export NVM_LAZY_LOAD=true
```

### Using NVM in CI/CD Pipelines

Integrate NVM into your CI/CD workflows for consistent environments:

```sh
nvm install 18
nvm use 18
npm ci
npm test
```

### Leveraging Node Binary Mirrors

Work in restricted environments by using custom Node.js mirrors:

```sh
export NVM_NODEJS_ORG_MIRROR=https://custom-mirror.com/node/
```

---

## Troubleshooting

### Common Issues and Fixes

- **Problem**: `nvm: command not found`
  **Solution**: Ensure your shell profile is sourcing NVM correctly.

- **Problem**: Slow shell startup.
  **Solution**: Enable lazy loading with `export NVM_LAZY_LOAD=true`.

### macOS-Specific Tips

If you're using `zsh`, ensure your `.zshrc` includes:

```sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"
```

---

## Community and Support

Join the vibrant NVM community on [GitHub](https://github.com/nvm-sh/nvm) and [Discord](https://discord.gg/nodejs). Share your experiences, ask questions, and contribute to the project.

---

## License

NVM is open-source software licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
