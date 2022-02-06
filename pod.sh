#/bin/sh

read -p 'Set port mapping range: [int | str "int-int"]: ' POD_PORT_MAP

docker-compose \
  -f nvim.yaml \
  run \
  -p "${POD_PORT_MAP}:${POD_PORT_MAP}" \
  nvim

set +x;
