{ config, lib, ... }:
{
  networking = {
    enableIPv6 = false;
    hostName = "pi3";
    interfaces.eth0.useDHCP = true;
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
    interfaces = {
      wlan0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.114";
            prefixLength = 24;
          }
        ];
      };
    };
    networkmanager.wifi.backend = "wpa_supplicant";
    wireless = {
      # The interfaces wpa_supplicant will use. If empty, 
      # it will automatically use all wireless interfaces. 
      # networking.wireless.interfaces
      userControlled.enable = true;
      userControlled.group = "wheel";
      networks = {
        "EE-Hub-9iPp" = {
          pskRaw = "86c32237c9c090fa4179777708847b790082291a2c3086bd7a23d44daefc8ae7";
        };
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
  systemd.services.wpa_supplicant = {
    enable = true;
    serviceConfig.Restart = "always";
    wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  };
}
