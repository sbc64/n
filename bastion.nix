{ config, pkgs, lib, ... }:
let
  c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {}) {};
  hostname = "bastion-nixos";
  secrets = import <secrets>;
  firstOctals =  "10.100.0";
  opsLan = firstOctals + ".1/24";
  shared = import ./shared_attr.nix;
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/networking.nix # generated at runtime by nixos-infect
    ./common.nix
  ];

  environment.systemPackages = with pkgs; [
    wireguard
  ] ++ c.commonPackages ++ c.workPackages;

  services.dnscrypt-proxy2 = {
    enable = false;
    settings = {
      sources.public-resolvers = {
        urls = [ "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md" ];
        cache_file = "public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
    };
  };
  services.dnsmasq = {
    enable = true;
    servers = [ "127.0.0.1" "10.100.0.1" "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=wg0
      listen-address=${shared.bastion.wg.ip}
      interface=eth0
      listen-address=165.227.245.71
    '';
  };


  boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
  networking.firewall.allowPing = true;
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    trustedInterfaces = [ "wg0" ];
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ opsLan ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      privateKey = secrets."${hostname}".wg.pk;

      peers = [
        { 
          # stannis
          publicKey = shared.stannis.wg.pubkey;
          allowedIPs = [ shared.stannis.wg.ip ];
        }
        {
          # robert
          publicKey = shared.robert.wg.pubkey;
          allowedIPs = [ shared.robert.wg.ip ];
        }
      ];
    };
  };

  boot.cleanTmpDir = true;
  networking.hostName = hostname;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0SSm2avOhdiDaQ38q/3NbtrakOFY8jLXcvA9Syb6Xx sebas@mini" 
  ];
}
