#!/bin/sh

source ./.env

podman unshare chown ${XUID}:${XUID} -R ${HOST_CODE_PATH}

set +x;
