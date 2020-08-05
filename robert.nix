{ config, pkgs, lib, ... }:
let
  hostname="robert";
  net = {
    eth = {mac = "b8:27:eb:0b:00:64";name = "eth0"; };
    embeded = { name = "wlan0"; mac = "b8:27:eb:5e:55:31";};
    tplink = { name = "wlan1"; mac = "d0:37:45:6a:94:c3";};
  };
  f = ''SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{type}=="1",'';
in
{
  imports = [ 
    ./common.nix
    /etc/nixos/uk_wifi.nix
    (import ./wifi-ap.nix { lib=lib; pkgs=pkgs; interfaces=net; })
    (import ./wireguard.nix { config=config; hostname=hostname; })
  ];
  networking.usePredictableInterfaceNames = true;
  services.udev = {
    extraRules = ''
  ${f} ATTR{address}=="${net.eth.mac}", NAME="${net.eth.name}"
  ${f} ATTR{address}=="${net.tplink.mac}", NAME="${net.tplink.name}"
  ${f} ATTR{address}=="${net.embeded.mac}", NAME="${net.embeded.name}"
  '';
  };

  hardware = {
    firmware = with pkgs; [ 
      firmwareLinuxNonfree
      wireless-regdb
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
    # https://github.com/NixOS/nixpkgs/issues/82455
    kernelPackages = pkgs.linuxPackages_5_6;
    kernelParams = [
      "cma=32M"
      "nosplash"
      "noquiet"
    ];
    blacklistedKernelModules = [
      "ath9k_htc"
      "ath9k_common"
      "ath9k_hw"
      "ath"
      "hcio"
    ];

    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=16
          dtoverlay=disable-bt
          dtoverlay=disable-wifi
          dtoverlay=pi3-disable-wifi
          dtoverlay=pi3-disable-bt
        '';
      };
      timeout = 2;
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
    hostName = hostname;
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
      eth0 = {
        ipv4.addresses = [
         { address="10.10.10.2"; prefixLength=24; }
       ];
      };
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
