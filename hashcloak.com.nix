{config, pkgs, ...}:
let
  root = builtins.fetchGit {
    url = "https://github.com/hashcloak/hashcloak.github.io.git";
    ref = "master";
  };
in
{
  services.nginx.enable = true;
  security.acme.email = "sebasheston@gmail.com";
  security.acme.acceptTerms = true;
  services.nginx.virtualHosts."hashcloak.com" = {
    forceSSL = true;
    enableACME = true;
    # We are using root because hashcloak.github.io redirects to hashcloak.com (this server)
    root = root;
    # These are just some alternative examples
    #globalRedirect = "https://hashcloak.com/";
    #locations."/" = {
      #return = "301 https://$host$request_uri;";
      #proxyPass = "https://hashcloak.github.io";
    #};
  };
}
