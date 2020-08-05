{ config, pkgs, interface }:
let
  secrets = import <secrets>;
  nmconnection = pkgs.writeText ''modem.nmconnection'' ''
  [connection]
  id=modem
  type=gsm
  permissions=
  autoconnect=true
  interface-name=${interface}

  [gsm]
  apn=giffgaff.com
  number=*99#
  password-flags=4
  pin-flags=4
  username=giffgaff

  [ppp]

  [ipv4]
  dns-search=
  method=auto

  [ipv6]
  addr-gen-mode=stable-privacy
  dns-search=
  method=auto

  [proxy]
  '';
in
{
  networking.networkmanager.enable = true;
  environment.etc."NetworkManager/system-connections/modem.nmconnection" = {
    mode = "0600";
    source = nmconnection;
  };
}
