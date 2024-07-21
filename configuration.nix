{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
  users.users.root.initialPassword = "password";
  users.users.root.openssh.authorizedKeys.keys =
    let
      content = pkgs.fetchurl {
        url = "https://github.com/dmytrokyrychuk.keys";
        sha256 = "sha256-aoFxPt0c6XDOC1aIS3N/7nWhgLvyKEFE1xn+s9ne4mE=";
      };
    in
    pkgs.lib.splitString "\n" (builtins.readFile content);
  system.stateVersion = "24.11";
}
