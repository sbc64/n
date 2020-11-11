{ pkgs ? import <nixpkgs> {} }:
let
in
pkgs.dockerTools.buildImage {
  name = "openethereum";
  tag="v3.1.0";
  config = {
    Entrypoint = [ "${pkgs.openethereum}/bin/openethereum" ];
  };
}
