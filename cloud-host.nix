{ config, pkgs, lib, ... }:
let
  c = import ./common_attr.nix {};
  # I'm leaving this commented to show multiples ways of how this
  # can be imported
  #c = pkgs.callPackage ./common_attr.nix {};
  #c = lib.recursiveUpdate (pkgs.callPackage ./common_attr.nix {})
  extraPackages = [];
in
{
  imports = [ 
    ./common.nix
    ./docker-metrics.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment.systemPackages = with pkgs; extraPackages ++ c.commonPackages ++ c.workPackages;

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };
}
