{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pve_ssh_tgt = "root@pve01.home.kyrych.uk";
      vmid = "XXX"; # set to the next available VM ID
      hostname = "nixos-lxc-test";
      allowDestroy = ""; # set to "yes" to allow destroy

      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [ nixos-rebuild ];
      };
      nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nix.registry.nixpkgs.flake = nixpkgs; }
          ./configuration.nix
        ];
      };

      packages.x86_64-linux.create-ct =
        let
          tarball = self.nixosConfigurations."${hostname}".config.system.build.tarball;
          imageFile = "${hostname}-nixos-system-x86_64-linux.tar.xz";
        in
        pkgs.writeShellScriptBin "create-ct" ''
          scp ${tarball}/tarball/nixos-system-x86_64-linux.tar.xz ${pve_ssh_tgt}:/var/lib/vz/template/cache/${imageFile}
          ssh ${pve_ssh_tgt} "pct create ${vmid} local:vztmpl/${imageFile} --hostname ${hostname} --net0 name=eth0,bridge=vmbr0,firewall=1,ip=dhcp,type=veth --storage local-zfs --features nesting=1 && pct start ${vmid}"
        '';
      packages.x86_64-linux.update-ct = pkgs.writeShellScriptBin "update-ct" ''
        nixos-rebuild switch --flake .#${hostname} --target-host root@${hostname}.home.kyrych.uk
      '';
      packages.x86_64-linux.reboot-ct = pkgs.writeShellScriptBin "reboot-ct" ''
        ssh ${pve_ssh_tgt} "pct reboot ${vmid}"
      '';
      packages.x86_64-linux.destroy-ct = pkgs.writeShellScriptBin "destroy-ct" ''
        if [[ "${allowDestroy}" != "yes" ]]; then
          echo 'Destroy not allowed'
          exit 1
        fi
        ssh ${pve_ssh_tgt} "pct stop ${vmid}; pct destroy ${vmid} --destroy-unreferenced-disks=true; pct status ${vmid};"
        echo "VM ${vmid} destroyed"
      '';
      packages.x86_64-linux.ssh = pkgs.writeShellScriptBin "ssh" ''
        ssh root@${hostname}.home.kyrych.uk
      '';

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;
    };
}
