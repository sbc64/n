{
  stannis.wg = {
    ip= "10.100.0.2/32";
    pubkey = "bsWyv2TGZeqXqc+dSX3J6sHhPa8z5Eg3ahrqXG9aNxI=";
  };
  robert.wg = {
    ip = "10.100.0.3/32";
    pubkey = "zll0iq9EDn1wab+rMGoccVvV2AdHfpNJdi3RkvCcdys=";
  };
  bastion.wg = {
    endpoint = "165.227.245.71:51820";
    allowedIPs = [ "10.100.0.0/24" ];
    pubkey = "BbLNXeBKEiiibTt9Jux/VkqygYRE3ckChiwzoQierHE=";
  };
}
