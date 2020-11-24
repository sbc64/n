{ config, hostname, server }:
let
  secrets = import ./secrets.nix;
  shared = import ./shared_attr.nix;
  interface = "wg0";
in
{
  networking.firewall.trustedInterfaces = [ interface ];
  networking.wg-quick.interfaces."${interface}" = {
    address = shared."${hostname}".wg.localIp;
    privateKey = secrets.${hostname}.wg.pk;
    peers = [
      {
        allowedIPs = shared.${hostname}.wg.localCaptureRange;
        endpoint = shared.bastion.wg.endpoint;
        publicKey = shared.bastion.wg.pubkey;
        persistentKeepalive = 25;
      }
    ];
  };
}
