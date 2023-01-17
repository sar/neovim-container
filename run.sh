#!/bin/sh

source ./.env

BUILD_TAG=latest
read -p 'Set port mapping range: [int | str "int-int"]: ' POD_PORT_MAP
echo "Exposing host port: ${POD_PORT_MAP}"

podman run \
  --rm \
  --env-file .env \
  --user ${XUID} \
  --userns=keep-id \
  -v ${HOST_CODE_PATH}:${CODE_PATH} \
  -v ${HOST_NVIM_PATH}/env:/home/${DEFAULT_USER} \
  -v ${HOST_NVIM_PATH}:/home/${DEFAULT_USER}/.config/nvim \
  -v tmpfs_cache:/tmp/NuGetScratch \
  -v nvim_cache:/home/${DEFAULT_USER}/.local/share/nvim \
  -v nvim_cache:/home/${DEFAULT_USER}/.cache/nvim \
  -v nvim_logs:/var/log \
  -p "${POD_PORT_MAP}:${POD_PORT_MAP}" \
  -i \
  -t localhost/nvim:${BUILD_TAG} \
  nvim

set +x;
