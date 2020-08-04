{ config, antenna, ...}:
let
  secrets = import <secrets>;
in
{
  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
    wireless.networks."EE-Hub-9iPp" = {
      pskRaw = secrets.uk-wifi.psk;
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
  };
}
