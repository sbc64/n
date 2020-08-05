{ config, pkgs, lib, ... }:
let
  qca9271 = pkgs.callPackage ./qca9271_firmware.nix { };
in
{
  imports = [ 
    ./common.nix
    /etc/nixos/uk_wifi.nix
    /etc/nixos/wifi-ap.nix
  ];

  hardware = {
    firmware = with pkgs; [ 
      firmwareLinuxNonfree
      wireless-regdb
      qca9271
    ];
    enableRedistributableFirmware = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  boot = {
    kernelPackages = pkgs.linuxPackages_5_6;
    kernelParams = [
      "cma=32M"
      "nosplash"
      "noquiet"
    ];
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
    wireless = {
	enable = true;
	interfaces = [ "wlan1" ];
   };
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan1";
    };
    nameservers = [
      "1.1.1.1"
    ];

    interfaces = {
      wlan1 = {
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
