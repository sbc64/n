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
  ];
  # Values configurable values
  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
    wireless.networks."EE-Hub-9iPp" = {
      pskRaw = "86c32237c9c090fa4179777708847b790082291a2c3086bd7a23d44daefc8ae7";
    };
  };
  users = {
    users.root = {
      hashedPassword = "$7$UvihnRZQ94c$O3.dGzLep0aqSXcqQTnN4nVArLAHaCP.nq1zSc.N/cCW4oCWudNIFu84Vp81fNDK/u3nZXfJ6qji0/zFxn5V9/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0SSm2avOhdiDaQ38q/3NbtrakOFY8jLXcvA9Syb6Xx"
      ];
    };
  };

  # Fixed values
  sdImage.compressImage = false;
  networking.wireless.userControlled = {
    enable = true;
    group = "wheel";
  };

  services.sshd.enabled = true;
  systemd = {
    services = {
      sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
      wpa_supplicant = {
        enable = true;
        serviceConfig.Restart = "always";
        wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
      };
    };
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
  environment.systemPackages = with pkgs; [
     wget
     vim
     git # not gitFull because it takes too long
     nmap
     curl
     htop
     bind
     less
     traceroute
     ethtool
     netcat
  ];

  system = {
    copySystemConfiguration = true; # ALWAYS HAVE THIS JUST INCASE
    stateVersion = "20.03"; # Did you read the comment?
  };
}
