{ config, interface, ip, secrets ? import <secrets> }:
let
in
{
  networking = {
    defaultGateway = {
      address = secrets.uk-wifi.gw;
      interface = interface;
    };
    wireless = {
      enable = true;
      interfaces = [ interface ];
    };
    networkmanager.unmanaged = [ interface ];
    wireless.networks."${secrets.uk-wifi.ssid}" = {
      pskRaw = secrets.uk-wifi.psk;
    };
    interfaces = {
      "${interface}" = {
        useDHCP = false;
        ipv4.addresses = [
          { address=ip; prefixLength = 24; }
        ];
      };
    };
  };
}
