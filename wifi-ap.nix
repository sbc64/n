{ lib, pkgs, ... }:

let
  wifi = "wlan0";
  ipAddress = "10.10.10.1";
  prefixLength = 24;
  servedAddressRange = "10.10.10.2,10.10.10.150,12h";
  ssid = "nixos";
  password = "supersecret";

in {
  # todo only open needed ports
  networking.firewall.trustedInterfaces = [ wifi ];
  networking.networkmanager.unmanaged = [ wifi ];
  networking.interfaces."${wifi}".ipv4.addresses = [{
    address = ipAddress;
    prefixLength = prefixLength;
  }];
  #networking.interfaces."wlan1".ipv4.addresses = [{
  #  address = ipAddress;
  #  prefixLength = prefixLength;
  #}];
  networking.firewall.extraCommands = ''
	iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
  '';
   
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",ATTR{address}=="b8:27:eb:5e:55:31", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="wlan0"
  '';

  boot.kernel.sysctl = {
    "net.ipv4.conf.${wifi}.forwarding" = true;
    "net.ipv6.conf.${wifi}.forwarding" = true;
  #  "net.ipv4.conf.wlan1.forwarding" = true;
  #  "net.ipv6.conf.wlan1.forwarding" = true;
  };

  systemd.services.hostapd = {
  description = "Hostapd";
  path = [ pkgs.hostapd ];
  wantedBy = [ "network.target" ];
  after = [
    "${wifi}-cfg.service"
    "nat.service"
    "bind.service"
    "dhcpd.service"
    "sys-subsystem-net-devices-${wifi}.service"
  ];
  serviceConfig = {
    ExecStart = "${pkgs.hostapd}/bin/hostapd ${
      pkgs.writeText "hostapd.conf" ''
        interface=${wifi}
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
      interface=${wifi}

      # Explicitly specify the address to listen on
      listen-address=${ipAddress}

      # Dynamic range of IPs to make available to LAN PC and the lease time.
      # Ideally set the lease time to 5m only at first to test everything works okay before you set long-lasting records.
      dhcp-range=${servedAddressRange}
    '';
  };
}
