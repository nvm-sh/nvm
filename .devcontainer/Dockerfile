# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.183.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}
LABEL name="nvm-dev-conteriner"
LABEL version="latest"

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

# ShellCheck version
ENV SHELLCHECK_VERSION=0.7.0

# Install apt packages
RUN apt-get update         && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  && \
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"     \
        coreutils             \
        util-linux            \
        bsdutils              \
        file                  \
        openssl               \
        libssl-dev            \
        locales               \
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
        zsh                   \
        ksh                   \
        gcc                   \
        g++                   \
        xz-utils              \
        build-essential       \
        bash-completion       && \
    apt-get clean

RUN wget https://github.com/koalaman/shellcheck/releases/download/v$SHELLCHECK_VERSION/shellcheck-v$SHELLCHECK_VERSION.linux.x86_64.tar.xz -O- | \
    tar xJvf - shellcheck-v$SHELLCHECK_VERSION/shellcheck          && \
    mv shellcheck-v$SHELLCHECK_VERSION/shellcheck /bin             && \
    rmdir shellcheck-v$SHELLCHECK_VERSION

# Set locale
# Add user "nvm" as non-root user
# Set sudoer for "nvm"
RUN locale-gen en_US.UTF-8 \
    && useradd -ms /bin/bash nvm \
    && echo 'nvm ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Switch to user "nvm" from now
USER nvm

# # nvm
# RUN echo 'export NVM_DIR="\Workspace"' >> "$HOME/.bashrc"
# RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$HOME/.bashrc"
# RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> "$HOME/.bashrc"

# # nodejs and tools
# RUN bash -c 'source $NVM_DIR/nvm.sh && \
#     nvm install node && \
#     npm install -g doctoc urchin eclint dockerfile_lint && \
#     npm install --prefix "$HOME/.nvm/"'
