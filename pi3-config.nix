{ config, pkgs, lib, ... }:
{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/common.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
  };

  networking = {
    enableIPv6 = false;
    hostName = "pi3";
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };

    interfaces = {
      eth0 = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address="1.1.1.2";
            prefixLength = 24;
          }
        ];
      };
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
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
    };
  };
}
