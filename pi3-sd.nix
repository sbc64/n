{ config, pkgs, lib, ... }:
# Install nixos-generate:
#nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
# Run with:
# nixos-generate -f sd-aarch64-installer --system aarch64-linux -c ./pi3-sd.nix -I nixpkgs=./nixpkgs
# raspberry pi needs to have a memory patch:
# git clone --depth=1 -b release-20.03 https://github.com/NixOS/nixpkgs
# cd nipkgs
# curl -L "https://github.com/NixOS/nixpkgs/pull/82718.patch" | git am
# Run the above in the nixpkgs submodule
# The above might not be needed once this gets merged
# https://github.com/NixOS/nixpkgs/pull/82718
#
# This config just bootstraps the pi3 to a network headlessly
# You need to eable this in your host machine config:
# boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    ./common.nix
    ./uk_wifi.nix
  ];

  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
  };

  # Fixed values
  sdImage.compressImage = false;
  networking.wireless.userControlled = {
    enable = true;
    group = "wheel";
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  boot = {
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

}
