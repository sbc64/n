{ config, interface, ip }:
let
  secrets = import <secrets>;
in
{
  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = interface;
    };
    nameservers = [
        "1.1.1.1"
    ];

    wireless.enable = true;
    networkmanager.unmanaged = [ interface ];
    wireless.networks."EE-Hub-9iPp" = {
      pskRaw = secrets.uk-wifi.psk;
    };
    interfaces = {
      "${interface}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address=ip;
            prefixLength = 24;
          }
        ];
      };
    };

  };
}
