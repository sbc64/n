{ config, interface, ip, secrets ? import <secrets> }:
let
  shared = import ./shared_attr.nix;
in
{
  networking = {
    defaultGateway = {
      address = secrets.uk-wifi.gw;
      interface = interface;
    };
    nameservers = [
      shared.bastion.wg.ip
      "1.1.1.1"
    ];

    wireless.enable = true;
    networkmanager.unmanaged = [ interface ];
    wireless.networks."secrets.uk-wifi.ssid" = {
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
