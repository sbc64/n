{ config, ...}:
let
  secrets = import <secrets>;
in
{
  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan1";
    };
    wireless.networks."EE-Hub-9iPp" = {
      pskRaw = secrets.uk-wifi.psk;
    };
  };
}
