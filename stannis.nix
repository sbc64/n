{ config, pkgs, lib, ... }:
let
  c = import ./common_attr.nix {};
  # I'm leaving this commented to show multiples ways of how this
  # can be imported
  #c = pkgs.callPackage ./common_attr.nix {};
  #c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {})
  hostname = "stannis";
  net = {
    interface = {
      ip="192.168.1.160";
      name="wlan0";
      mac="08:11:96:a3:6b:cc";
    };
    modem = {
      name="gsm0";
      mac="0c:5b:8f:27:9a:64";
    };
    atheros = {
      ip="192.168.1.162";
      name="wlan1";
      mac = "00:c0:ca:98:ab:75";
    };
    eth = {
      ip="10.10.10.10";
      name="eth0";
      mac = "f0:de:f1:a5:6c:ef";
    };
  };
  f = ''SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{type}=="1",'';
in
{

  networking = {
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address=net.eth.ip; prefixLength=24; }
        ];
      };
    };
  };

  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./common.nix
    ./beacon_prysm.nix
    (import ./modem.nix {
      config=config;
      pkgs=pkgs;
      interface=net.modem.name;
    })
    (import ./uk_wifi.nix {
      config=config;
      interface=net.interface.name;
      ip=net.interface.ip;
    })
    (import ./wireguard.nix { config=config; hostname=hostname; })
  ];

  networking.usePredictableInterfaceNames = true;
  services.udev = {
    extraRules = ''
  ${f} ATTR{address}=="${net.interface.mac}", NAME="${net.interface.name}"
  ${f} ATTR{address}=="${net.eth.mac}", NAME="${net.eth.name}"
  ${f} ATTR{address}=="${net.atheros.mac}", NAME="${net.atheros.name}"

  ${f} ATTR{address}=="${net.modem.mac}", NAME="${net.modem.name}"
  ATTR{idVendor}=="12d1", ATTR{idProduct}=="14f0", RUN+="${pkgs.usb_modeswitch}/bin/usb_modeswitch -J '%b/%k'"
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
