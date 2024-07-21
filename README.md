# NixOS on Proxmox LXC

This flake provides commands to create/update LXC containers on my Proxmox server.

## Usage

1. `nix run .#create-ct` builds an image, uploads it to proxmox anc creates a
container based on the new image.
2. `nix run .#update-ct` is `nixos-rebuild switch --target-host=...`. This
command may fail if the container is not rebooted at least once after creation;
run `nix run .#reboot-ct` to reboot the container remotely.
3. `nix run .#destroy-ct` removes the container. This is a destructive action
and it is disabled by default. Follow the directions in the source code of the
command to enable the deletion.
4. `nix run .#ssh` opens up an ssh session to the container. The container is
expected to have an ssh server running for this command to work.
