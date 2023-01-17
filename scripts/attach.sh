#/bin/sh

docker ps -a

read -p 'Set container id [str]: ' POD_CONTAINER_ID

NVIM_PATH=/usr/local/sbin/nvim

docker exec \
  -it \
  "${POD_CONTAINER_ID}" \
  ${NVIM_PATH}

set +x;
