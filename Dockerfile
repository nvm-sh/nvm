# Dockerized nvm development environment
#
# This Dockerfile is for building nvm development environment only,
# not for any distribution/production usage.
#
# Please note that it'll use about 1.2 GB disk space and about 15 minutes to
# build this image, it depends on your hardware.

# Use Ubuntu Trusty Tahr as base image as we're using on Travis CI
# I also tested with Ubuntu 16.04, should be good with it!
From ubuntu:14.04
MAINTAINER Peter Dave Hello <hsu@peterdavehello.org>

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

# Pick a Ubuntu apt mirror site for better speed
# ref: https://launchpad.net/ubuntu/+archivemirrors
ENV UBUNTU_APT_SITE ubuntu.cs.utah.edu

# Disable src package source
RUN sed -i 's/^deb-src\ /\#deb-src\ /g' /etc/apt/sources.list

# Replace origin apt pacakge site with the mirror site
RUN sed -E -i "s/([a-z]+.)?archive.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list
RUN sed -i "s/security.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list

# Install apt packages
RUN apt update         && \
    apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  && \
    apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"     \
        coreutils             \
        util-linux            \
        bsdutils              \
        file                  \
        openssl               \
        ca-certificates       \
        ssh                   \
        wget                  \
        patch                 \
        sudo                  \
        htop                  \
        dstat                 \
        vim                   \
        tmux                  \
        curl                  \
        git                   \
        jq                    \
        realpath              \
        zsh                   \
        ksh                   \
        ghc                   \
        gcc-4.8               \
        g++-4.8               \
        cabal-install         \
        build-essential       \
        bash-completion       && \
    apt-get clean

# Set locale
RUN locale-gen en_US.UTF-8

# Print tool versions
RUN bash --version | head -n 1
RUN zsh --version
RUN ksh --version || true
RUN dpkg -s dash | grep ^Version | awk '{print $2}'
RUN git --version
RUN curl --version
RUN wget --version
RUN cabal --version

# Add user "nvm" as non-root user
RUN useradd -ms /bin/bash nvm

# Set sudoer for "nvm"
RUN echo 'nvm ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Switch to user "nvm" from now
USER nvm

# Shellcheck
RUN cabal update
RUN cabal install ShellCheck
RUN ~/.cabal/bin/shellcheck --version
RUN echo 'export PATH="~/.cabal/bin/:${PATH}"'                                >> $HOME/.bashrc

# nvm
COPY . /home/nvm/.nvm/
RUN sudo chown nvm:nvm -R $HOME/.nvm
RUN echo 'export NVM_DIR="$HOME/.nvm"'                                        >> $HOME/.bashrc
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> $HOME/.bashrc
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> $HOME/.bashrc

# nodejs and tools
RUN bash -c 'source $HOME/.nvm/nvm.sh   && \
    nvm install node                    && \
    npm install -g doctoc urchin        && \
    npm install --prefix "$HOME/.nvm/"'

# Set WORKDIR to nvm directory
WORKDIR /home/nvm/.nvm

ENTRYPOINT /bin/bash

