{ config, pkgs, lib, ... }:
{
  imports = [ 
    /etc/nixos/common.nix
    /etc/nixos/uk_wifi.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["cma=32M"];
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
      };
      timeout = 1;
    };
    cleanTmpDir = true;
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 10d";
  };

  networking = {
    enableIPv6 = false;
    hostName = "robert";
    wireless.enable = true;
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
    interfaces = {
      wlan0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.114";
            prefixLength = 24;
          }
        ];
      };
    };

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
    };
  };
}
