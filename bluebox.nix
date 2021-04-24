{ config, pkgs, lib, ... }:
let
  c = import ./common_attr.nix {};
  secrets = import ./secrets.nix;
  # I'm leaving this commented to show multiples ways of how this
  # can be imported
  #c = pkgs.callPackage ./common_attr.nix {};
  #c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {})
  hostname = "bluebox";
  net = {
    wlp2s0 = {
      ip="192.168.0.36";
      name="wlp2s0";
      mac = "e0:ca:94:61:0d:93";
    };
    enp1s0 = {
      ip="192.168.1.186";
      name="enp1s0";
      mac = "00:fa:5c:68:4c:66";
    };
  };
  f = ''SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{type}=="1",'';
in
{
  networking = {
    nameservers = [
      "1.1.1.1"
    ];
    interfaces = {
      "${net.enp1s0.name}" ={
        useDHCP = true;
        ipv4 = {
          addresses = [
            { address=net.enp1s0.ip; prefixLength=24; }
          ];
          routes = [
          ];
        };
      };
    };
  };

  boot.initrd.luks.devices = {
      "tg" = {
        device = "/dev/disk/by-uuid/2031fdab-7337-42ca-8705-5ce97d729621";
        keyFile = "/dev/disk/by-uuid/4117-B332";
        keyFileSize = 4096;
        keyFileOffset = 81920;
        preLVM = false;
        fallbackToPassword = true;
    };
  };
  boot.initrd.network = {
    ssh = {
      enable = false;
      hostKeys =  [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    enable = true;
  };
  fileSystems."/mnt/tg" = {
      device = "/dev/disk/by-uuid/ad16e148-1449-4521-8a3b-54951e6aa1dd";
      fsType = "ext4";
      options = [ "nofail,x-systemd.mount-timeout=5s"];
  };

  imports = [ 
    ./tg.nix
    /etc/nixos/hardware-configuration.nix
    ./common.nix
    (import ./uk_wifi.nix {
      inherit config secrets;
      interface=net.wlp2s0.name;
      ip=net.wlp2s0.ip; })
    (import ./stakers/wireguard.nix { inherit secrets config hostname; server = "server"; enabled=true;})
  ];

  networking.usePredictableInterfaceNames = true;
  services.udev.extraRules = ''
    ${f} ATTR{address}=="${net.wlp2s0.mac}", NAME="${net.wlp2s0.name}"
    ${f} ATTR{address}=="${net.enp1s0.mac}", NAME="${net.enp1s0.name}"
  '';

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment.systemPackages = with pkgs; [
  ] ++ c.commonPackages ++ c.workPackages;

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
