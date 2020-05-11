{ config, pkgs, lib, ... }:
# Install nixos-generate:
#nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
# Run with:
# nixos-generate -f sd-aarch64-installer --system aarch64-linux -c ./pi3-sd.nix -I nixpkgs=./nixpkgs
# raspberry pi needs to have a memory patch:
# curl -L "https://github.com/NixOS/nixpkgs/pull/82718.patch" | git am
{
  imports = [
    ./networking.nix
    ./base.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
  ];
  
  #kernelPackages = pkgs.linuxPackages_rpi3;
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  boot = {
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
  };
  sdImage.compressImage = false;
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services.sshd.enabled = true;
}
