{ config, pkgs, lib, ... }:
let
  c = import ./common_attr.nix {};
  # I'm leaving this commented to show multiples ways of how this
  # can be imported
  #c = pkgs.callPackage ./common_attr.nix {};
  #c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {})
  hostname = "stannis";
  net = {
    wlan0 = {
      ip="192.168.1.231";
      name="wlan0";
      mac="08:11:96:a3:6b:cc";
    };
    eth = {
      ip="192.168.1.3";
      name="eth0";
      mac = "f0:de:f1:a5:6c:ef";
    };
  };
  f = ''SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{type}=="1",'';
in
{

  networking = {
    interfaces = {
      eth0.ipv4 = {
        addresses = [
          { address=net.eth.ip; prefixLength=24; }
        ];
        routes = [
          { address=net.eth.ip; prefixLength=24; via = "192.168.1.1"; }
        ];
      };
    };
  };

  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./common.nix
    (import ./uk_wifi.nix {
      config=config;
      interface=net.wlan0.name;
      ip=net.wlan0.ip;
    })
    (import ./wireguard.nix { config=config; hostname=hostname; server = "server"; })
  ];

  networking.usePredictableInterfaceNames = true;
  services.udev = {
    extraRules = ''
  ${f} ATTR{address}=="${net.wlan0.mac}", NAME="${net.wlan0.name}"
  ${f} ATTR{address}=="${net.eth.mac}", NAME="${net.eth.name}"
  '';
  };

  hardware.usbWwan.enable = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment.systemPackages = with pkgs; [
    modemmanager
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
    hostName = hostname;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  virtualisation.docker = {
    liveRestore = false;
    enable = true;
  };
}
