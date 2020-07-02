{ lib, pkgs, ... }:
let
  apInterface = "wlan0";
  internetInterface = "wlan1";
  ipAddress = "10.10.10.1";
  prefixLength = 24;
  servedAddressRange = "10.10.10.2,10.10.10.150,12h";
  ssid = "kerbal_optout_nomap";
  password = "-@SiberianSensuousReroute=";
in {
  imports = [ ./mac.nix ];

  networking.firewall.trustedInterfaces = [ apInterface internetInterface ];
  networking.networkmanager.unmanaged = [ apInterface internetInterface ];
  networking.interfaces."${apInterface}".ipv4.addresses = [{
    address = ipAddress;
    prefixLength = prefixLength;
  }];

  networking = {
    wireless.networks."EE-Hub-9iPp" = {
      #extraConfig = ''bssid_blacklist=ac:84:c6:b1:ee:d7'';
    };
  };
   
  systemd.network.enable = true;

  boot.kernel.sysctl = {
    "net.ipv4.conf.${apInterface}.forwarding" = true;
    "net.ipv4.conf.${internetInterface}.forwarding" = true;
  };


  systemd.services.hostapd = {
    description = "Hostapd";
    path = [ pkgs.hostapd ];
    wantedBy = [ "network.target" ];
    after = [
      "${apInterface}-cfg.service"
      "nat.service"
      "bind.service"
      "dhcpd.service"
      "sys-subsystem-net-devices-${apInterface}.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.hostapd}/bin/hostapd ${
        pkgs.writeText "hostapd.conf" ''
          interface=${apInterface}
          driver=nl80211
          ssid=${ssid}
          hw_mode=g
          channel=1
          ieee80211n=1
          wmm_enabled=1
          ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
          macaddr_acl=0
          auth_algs=1
          ignore_broadcast_ssid=0
          wpa=2
          wpa_key_mgmt=WPA-PSK
          wpa_passphrase=${password}
          rsn_pairwise=CCMP
        ''
      }";
      Restart = "always";
    };
  };
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      # Only listen to routers' LAN NIC.  Doing so opens up tcp/udp port 53 to
      # localhost and udp port 67 to world:
      interface=${apInterface}

      # Explicitly specify the address to listen on
      listen-address=${ipAddress}

      # Dynamic range of IPs to make available to LAN PC and the lease time.
      # Ideally set the lease time to 5m only at first to test everything works okay before you set long-lasting records.
      dhcp-range=${servedAddressRange}
    '';
  };
}
