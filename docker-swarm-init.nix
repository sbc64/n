with import <nixpkgs> {};
let
in
{
  virtualisation.docker = {
     enable = true;
     liveRestore = false;
     enableOnBoot = true;
     autoPrune.enable = true;
  };
  systemd.services.init-swarm = {
    description = "Init Docker swarm";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    script = ''
      IP=$(${pkgs.curl}/bin/curl -s https://ident.me)
      ${pkgs.docker}/bin/docker swarm init --advertise-addr=$IP || true
    '';
    serviceConfig = {
      Type="oneshot";
    };
  };
}
