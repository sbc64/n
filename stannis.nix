{ config, pkgs, lib, ... }:
let
  c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {}) {};
in
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

  environment.systemPackages = with pkgs; [
    wireguard
  ] ++ c.commonPackages ++ c.workPackages;

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
