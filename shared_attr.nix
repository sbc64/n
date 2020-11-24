let
  publicIP = "165.227.245.71";
in
{
  stannis.wg = {
    ip= "10.100.0.2/32";
    pubkey = "bsWyv2TGZeqXqc+dSX3J6sHhPa8z5Eg3ahrqXG9aNxI=";
  };
  robert.wg = {
    ip = "10.100.0.3/32";
    pubkey = "zll0iq9EDn1wab+rMGoccVvV2AdHfpNJdi3RkvCcdys=";
  };
  mini.wg = {
    localCaptureRange = [ "0.0.0.0/0" "::/0"];
    localIp = [ "10.100.0.4/24" ];
    serverAssigned = [ "10.100.0.4/32" ];
    pubkey = "HuQiO5nYdAXGG5zQX0Hqz/OsXL6tG+dk+hlMRPh9XAg=";
  };
  bastion.wg = {
    ip = "10.100.0.1";
    publicIP = publicIP;
    endpoint = publicIP + ":51820";
    allowedIPs = [ "10.100.0.0/24" ];
    pubkey = "BbLNXeBKEiiibTt9Jux/VkqygYRE3ckChiwzoQierHE=";
  };
}
