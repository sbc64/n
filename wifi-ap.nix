{ config, pkgs, lib, ... }:
{
  services.hostapd ={
    enable = true;
    channel = 11;
    driver = "nl80211";
    interface = "wlan0";
    ssid = "nixos";
    wpa = true;
    wpaPassphrase= "super_secret";
  };

  networking.dhcpcd = {
    allowInterfaces = [ "wlan0" ];
    extraConfig = ''
      interface wlan0
      static ip_address=192.168.0.10/24
      denyinterfaces eth0
      denyinterfaces wlan1
    '';
  };
}
