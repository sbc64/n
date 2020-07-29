{ config, pkgs, ... }:
let
  metricsPort = 9323;
in
{
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    enableOnBoot = true;
    autoPrune.enable = true;
    extraOptions = ''--metrics-addr=172.18.0.1:${metricsPort} --experimental'';
  };

  networking.firewall = {
    interfaces = {
      "docker_gwbridge".allowedTCPPorts = [ metricsPort ];
    };
    enable = true;
  };
}
