{ config, hostname, ... }:
let
  secrets = import <secrets>;
  interface = "wg0";
in
{
  networking.firewall.trustedInterfaces = [ interface ];
  networking.wg-quick.interfaces."${interface}" = {
    address = [ "10.100.0.2/32" ];
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
