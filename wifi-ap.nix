{ lib, pkgs, ... }:
let
  apInterface = "wlan0";
  internetInterface = "wlan1";
  antennaMac = "d0:37:45:6a:94:c3";
  ipAddress = "10.0.0.1";
  prefixLength = 24;
  servedAddressRange = "10.0.0.2,10.0.0.50,5m";
  ssid = "kerbal";
  password = "SiberianSensuousReroute94";
in {
  imports = [ ./mac.nix ];

  networking.firewall = {
    trustedInterfaces = [ apInterface internetInterface ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -o ${internetInterface} -j MASQUERADE
    '';
  };

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

   
  boot.kernel.sysctl = {
    "net.ipv4.conf.${apInterface}.forwarding" = true;
    "net.ipv4.conf.${internetInterface}.forwarding" = true;
  };

  systemd.services.check-ap = {
    description = "Reboots computer if the ${internetInterface} is not correct";
    wantedBy = [ "multi-user.targer" ];
    after = [ "hostapd.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeText "check-wifi.sh" ''
              wifi=$(${pkgs.coreutils}/bin/cat /sys/class/net/${internetInterface}/address)
              echo "Found MAC $wifi for ${internetInterface}"
              if [[ "$wifi" != "${antennaMac}" ]]; then
                 echo "rebooting..."
                 ${pkgs.systemd}/bin/systemctl reboot
              fi
          ''}";
      Type = "oneshot";
      Restart = "no";
    };
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
      ExecStart = "${pkgs.hostapd}/bin/hostapd -d ${
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
      interface=${apInterface}
      listen-address=${ipAddress}
      dhcp-range=${servedAddressRange}
    '';
  };
}
