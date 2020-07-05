{ lib, pkgs, ... }:
let
  antenna = { name = "wlan1"; mac =  "d0:37:45:6a:94:c3";};
  embeded = { name = "wlan0"; mac =  "b8:27:eb:5e:55:31";};
  ipAddress = "10.0.0.1";
  prefixLength = 24;
  servedAddressRange = "10.0.0.2,10.0.0.50,24h";
  ssid = "kerbal_optout_nomap";
  password = "SiberianSensuousReroute94";
  repeaterBSSID = "ac:84:c6:b1:ee:d7";
  apBSSID = "04:a2:22:12:47:9c";
  rules = ''
  SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${embeded.mac}", NAME="${embeded.name}", ATTR{type}=="1"
  SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${antenna.mac}", NAME="${antenna.name}", ATTR{type}=="1"
  '';

  udevNetSetupLinkRules = pkgs.writeTextFile {
    name = "80-net-setup-link.rules";
    destination = "/etc/udev/rules.d/80-net-setup-link.rules";
    text = ''
      ${rules}
      SUBSYSTEM!="net", GOTO="net_setup_link_end"
      IMPORT{builtin}="path_id"
      ACTION!="add", GOTO="net_setup_link_end"
      ${rules}
      LABEL="net_setup_link_end"
    '';
  };
in {
  networking.firewall = {
    trustedInterfaces = [ embeded.name antenna.name ];
    extraCommands = ''
      iptables -t nat -A POSTROUTING -o ${antenna.name} -j MASQUERADE
    '';
  };

  networking.networkmanager.unmanaged = [ embeded.name antenna.name ];
  networking.interfaces."${embeded.name}".ipv4.addresses = [{
    address = ipAddress;
    prefixLength = prefixLength;
  }];

  networking = {
    wireless.networks."EE-Hub-9iPp" = {
    # This doesn't work for some reason and causes wpa to fail
    # to associate with the router ap
    #extraConfig = ''
    #  bssid_blacklist=${repeaterBSSID}
    #'';
    };
  };

   
  boot.kernel.sysctl = {
    "net.ipv4.conf.${embeded.name}.forwarding" = true;
    "net.ipv4.conf.${antenna.name}.forwarding" = true;
  };

  systemd.services.check-ap = {
    description = "Reboots computer if the ${antenna.name} is not correct";
    wantedBy = [ "multi-user.targer" ];
    after = [ "hostapd.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeText "check-wifi.sh" ''
              wifi=$(${pkgs.coreutils}/bin/cat /sys/class/net/${antenna.name}/address)
              echo "Found MAC $wifi for ${antenna.name}"
              if [[ "$wifi" != "${antenna.mac}" ]]; then
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
      "${embeded.name}-cfg.service"
      "nat.service"
      "bind.service"
      "dhcpd.service"
      "sys-subsystem-net-devices-${embeded.name}.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.hostapd}/bin/hostapd -d ${
        pkgs.writeText "hostapd.conf" ''
          interface=${embeded.name}
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
      interface=${embeded.name}
      listen-address=${ipAddress}
      dhcp-range=${servedAddressRange}
    '';
  };

  networking.usePredictableInterfaceNames = true;
  boot.initrd = {
    extraUdevRulesCommands = ''
      cp -v -f ${pkgs.systemd}/lib/udev/rules.d/75-net-description.rules $out
      cp -v -f ${udevNetSetupLinkRules}/etc/udev/rules.d/80-net-setup-link.rules $out/
    '';
  };

  services.udev.extraRules = rules;
# this enabled systemd-resolved which conflicts with dnsmasq on port 53
  systemd.network.enable = false; 
  systemd.network.links = {
    "antenna" = {
      enable = true;
      linkConfig = { MACAddress = antenna.mac; };
      matchConfig = { Name = antenna.name; };
    };
    "embeded" = {
      enable = true;
      linkConfig = { MACAddress = embeded.mac; };
      matchConfig = { Name = embeded.name; };
    };
  };
}
