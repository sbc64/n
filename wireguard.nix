{ config, hostname }:
let
  secrets = import <secrets>;
  shared = import ./shared_attr.nix;
  interface = "wg0";
in
{
  networking.firewall.trustedInterfaces = [ interface ];
  networking.wg-quick.interfaces."${interface}" = {
    address = [ shared."${hostname}".wg.ip ];
    privateKey = secrets."${hostname}".wg.pk;
    peers = [
      {
        allowedIPs = shared.bastion.wg.allowedIPs;
        endpoint = shared.bastion.wg.endpoint;
        publicKey = shared.bastion.wg.pubkey;
      }
    ];
  };
}
