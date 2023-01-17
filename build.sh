#!/bin/sh

source ./.env
source ./SUDO_PASSWORD
read -p '[var]: Enter root passwd for container user: ' SUDO_PASSWORD
echo $SUDO_PASSWORD >> .sudo 
printf `\n[warn]: passwd=$SUDO_PASSWORD will be inspectable in contaner build \n`

export https_proxy=${HTTPS_PROXY}

podman build \
  -f Dockerfile \
  --build-arg HOST_GID=$HOST_GID \
  --build-arg DEFAULT_USER=$DEFAULT_USER \
  --build-arg SUDO_PASSWORD=$SUDO_PASSWORD \
  --build-arg HTTPS_PROXY=$HTTPS_PROXY \
  .

set +x;
