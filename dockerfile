# --------------
# BASE IMAGE
# --------------
FROM debian:bullseye

# --------------
# ARGS
# --------------
ARG HOST_GID
ARG DEFAULT_USER
ARG SUDO_PASSWORD

# --------------
# USER
# --------------
RUN useradd ${DEFAULT_USER} && \
    usermod -aG sudo ${DEFAULT_USER} && \
    echo ${DEFAULT_USER}:${SUDO_PASSWORD} | chpasswd && \
    mkdir /home/${DEFAULT_USER} && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}

# --------------
# Package: APT Transport HTTPs
# --------------
COPY pkgs /tmp/pkgs
RUN dpkg -i /tmp/pkgs/*.deb

# --------------
# Repos: Replace Sources, APT over HTTPs
# --------------
COPY pkgs/sources.list /etc/apt/sources.list

# --------------
# Update: System Packages, Dependencies
# --------------
RUN apt-get update && \
    apt-get upgrade -y && \
    apt install -y \
        ansible \
        bash \
        build-essential \
        curl \
        ffmpeg \
        g++ \
        gcc \
        gnupg-agent \
        htop \
        libffi-dev \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        ranger \
        software-properties-common \
        sshpass \
        sudo \
        systemd \
        tar \
        tree \
        unzip \
        vim \
        wget

# --------------
# NodeJS
# --------------
RUN wget https://raw.githubusercontent.com/nodesource/distributions/master/deb/setup_14.x -O /tmp/nodejs_14_setup.sh && \
    chmod +x /tmp/nodejs_14_setup.sh && \
    /tmp/nodejs_14_setup.sh && \
    apt install -y nodejs && \
    node -v && npm -v \
    npm config set python python3

# --------------
# nvim
# --------------
WORKDIR /tmp
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-linux64.tar.gz && \
    tar xzvf nvim-linux64.tar.gz && \
    ls -la .

# --------------
# Podman: Runtime
# --------------
# docker-compose
RUN wget https://download.docker.com/linux/debian/gpg -O docker.gpg && \
    apt-key add docker.gpg && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt install -y \
        docker-compose && \
    apt remove -y golang-docker-credential-helpers

# Podman
RUN apt install -y podman

# Podman Config
RUN id $DEFAULT_USER && \
    systemctl enable podman.socket

# --------------
# SDK: Dotnet Core
# --------------
RUN wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt install -y \
        dotnet-sdk-6.0 \
        dotnet-runtime-6.0 \
        dotnet-sdk-5.0 \
        dotnet-runtime-5.0 \
        dotnet-sdk-3.1 \
        dotnet-runtime-3.1 \
        dotnet-sdk-2.1 \
        dotnet-runtime-2.1 && \
    dotnet tool install -g dotnet-ef && \
    dotnet new --install Amazon.Lambda.Templates::5.8.0 && \
    dotnet tool install -g Amazon.Lambda.Tools && \
    dotnet tool install -g JetBrains.ReSharper.GlobalTools && \
    chown -R $DEFAULT_USER:$DEFAULT_USER /tmp/NuGetScratch

# --------------
# SDK: AWS CLI, aws-shell
# --------------
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    pip3 install aws-shell --user

# --------------
# SDK: Azure CLI
# --------------
RUN curl -sL https://aka.ms/InstallAzureCLIDeb -o azure_cli.sh && \
    chmod +x azure_cli.sh && \
    ./azure_cli.sh

# --------------
# NPM: Packages
# --------------
RUN npm install -g yarn

RUN yarn global add \
    webpack-cli \
    create-react-app \
    gatsby \
    gulp \
    @aws-amplify/cli \
    @storybook/cli

# --------------
# PKG: Nektos ACT
# --------------
RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | /bin/bash

# --------------
# PKG: Terraform
# --------------
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && \
    apt install -y terraform

# --------------
# binaries:gitui, gh cli
# --------------
WORKDIR /tmp
# gitui
RUN wget https://github.com/extrawurst/gitui/releases/download/v0.20.1/gitui-linux-musl.tar.gz && \
    tar -xzvf gitui-linux-musl.tar.gz && \
    ls -la gitui

# gh cli
USER root
RUN wget https://github.com/cli/cli/releases/download/v2.4.0/gh_2.4.0_linux_amd64.deb && \
    dpkg -i gh*_amd64.deb && \
    which gh

# --------------
# PostgreSQL tools
# --------------
RUN apt install -y \
      postgresql-client \
      pgcli \
      pspg

# --------------
# SEC: Fail2ban
# --------------
USER root
RUN apt install -y fail2ban && \
    wget https://raw.githubusercontent.com/sar/vs-code-container-with-ssl/main/config/jail.local -O /etc/fail2ban/jail.local && \
    systemctl enable fail2ban

# --------------
# SEC: ClamAV
# --------------
RUN apt install -y clamav clamav-daemon && \
    freshclam

# --------------
# SEC: Hosts
# --------------
RUN wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts -O /etc/hosts

# --------------
# APT: Cleanup
# --------------
RUN apt clean all

# --------------
# SET: PERMISSIONS
# --------------
USER ${DEFAULT_USER}
RUN mkdir -p ~/.config/gh && \
    chown -R ${DEFAULT_USER} ~/.config && \
    mkdir -p ~/.local/share/NuGet && \
    chown -R ${DEFAULT_USER} ~/.local/share/NuGet

# --------------
# EXPOSE RUNTIME PORTS
# --------------
EXPOSE 5000-5010 8000-8010

# --------------
# ENTRYPOINT: nvim
# --------------
USER $DEFAULT_USER
ENTRYPOINT [ "/tmp/nvim-linux64/bin/nvim" ];
