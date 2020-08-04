{ config, pkgs, lib, ... }:
let
  hostname="robert";
  net = {
    embeded = { name = "wlan0"; mac =  "b8:27:eb:5e:55:31";};
    tplink = { name = "wlan1"; mac =  "d0:37:45:6a:94:c3";};
    atheros = { name = "wlan2"; mac =  "00:c0:ca:98:ab:75";};
  };
  f = ''SUBSYSTEM=="net", ACTION=="add",DRIVERS=="?*",ATTR{type}=="1"'';
in
{
  services.udev.extraRules = ''
    ${f} ATTR{address}=="${net.embeded.mac}", NAME="${net.embeded.name}"
    ${f} ATTR{address}=="${net.tplink.mac}", NAME="${net.tplink.name}"
    ${f} ATTR{address}=="${net.atheros.mac}", NAME="${net.atheros.name}"
  '';
  systemd.network.links = {
    "tplink" = {
      enable = true;
      linkConfig = { MACAddress = net.tplink.mac; };
      matchConfig = { Name = net.tplink.name; };
    };
    "atheros" = {
      enable = true;
      linkConfig = { MACAddress = net.atheros.mac; };
      matchConfig = { Name = net.atheros.name; };
    };
  };

  networking = {
    enableIPv6 = false;
    hostName = hostname;
    #nameservers = [
    #  "1.1.1.1"
    #];

    firewall = {
      enable = false;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  imports = [ 
    #./common.nix
    (import ./uk_wifi.nix {config=config; antenna=net.embeded; })
    #(import ./wifi-ap.nix {lib=lib; pkgs=pkgs;antenna=net.atheros; })
  ];

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
    bluetooth.enable = false;
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
    ];
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=16
          #dtoverlay=disable-bt
          #dtoverlay=disable-wifi
          #dtoverlay=pi3-disable-wifi
          #dtoverlay=pi3-disable-bt
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

}
