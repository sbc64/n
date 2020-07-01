{ config, pkgs, lib, ... }:
{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/common.nix
    /etc/nixos/uk_wifi.nix
  ];

  boot = {
    kernel.sysctl."net.ipv4.ip_forward" = "1";
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services = {
    logind.lidSwitch = "ignore";
    xserver = {
      xkbOptions = "ctrl:nocaps,compose:ralt";
      libinput.enable = true;
    };
  };

  networking = {
    enableIPv6 = false;
    hostName = "stannis";
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlp3s0";
    };

    interfaces = {
      wlp3s0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.224";
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
