# Neovim Container

Launch [neovim](https://github.com/neovim/neovim) as a container in your homelab with preloaded dev tools, SDKs, and CLIs for React.js, TypeScript, C#, Python, etc development.

### Usage

Modify the [dockerfile](dockerfile) built on a `debian:bullseye` base image with required layers for dev tooling. Prior to running, clone the `.env.template` to `.env` and set the required variables for persisting code and neovim configs.

Build and attach shell to the running container using `$ docker-compose -f <yaml> run <task>` pointing to [nvim.yaml](nvim.yaml) and scoped to `nvim` container. Solution has been tested compatible with `podman` backend.

To customize the default nvim installation, check out the [neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch) series and clone it to the mapped volume.

### License

Project made available under the MIT License. For details refer to [LICENSE](license).

