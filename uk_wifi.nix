{ config, ...}:
{
  networking = {
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan1";
    };
    wireless.networks."EE-Hub-9iPp" = {
      pskRaw = "86c32237c9c090fa4179777708847b790082291a2c3086bd7a23d44daefc8ae7";
      #extraConfig = ''bssid_blacklist=ac:84:c6:b1:ee:d7'';
    };
  };
}
