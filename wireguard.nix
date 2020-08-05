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
        allowedIPs = [ "10.100.0.0/24" ];
        endpoint = "165.227.245.71:51820";
        publicKey = "BbLNXeBKEiiibTt9Jux/VkqygYRE3ckChiwzoQierHE=";
      }
    ];
  };
}
