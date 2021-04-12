{config, pkgs ? <nixpkgs>, ... }:
let
  network="--network=tg"; # docker network create medalla --driver bridge
  externalIp="136.244.116.42";
  rpcEth1Port="8545";
  image="sebohe/turbo-geth";
  tag="v2021.04.02";
  tg = pkgs.dockerTools.pullImage {
    imageName = image;
    finalImageTag = tag;
    imageDigest = "sha256:364fc9cf2ff415e3dd82a0d8d3be8d8f53808d15de1ccd06ee8c35d756f1fd9a";
    sha256 = "000003zq2v6rrhizgb9nvhczl87lcfphq9601wcprdika2jz7qh8";
  };
in
{
  docker-containers = {
    "turbo" = {
      image = tg.imageName+":"+tag;
      extraDockerOptions = [
        ''${network}''
        ''-p=10.1.0.9:30303:30303''
        ''-p=10.1.0.9:30303:30303/udp''
      ];
      volumes = [
        "/mnt/tg:/blockchain"
      ];
      cmd = [
        "tg"
        "--datadir=/blockchain"
        "--storage-mode=hrt"
        "--nat=extip:${externalIp}"
        "--v5disc"
        "--private.api.addr=0.0.0.0:9090"
      ];
    };
   "rpcdaemon" = {
     image = tg.imageName+":"+tag;
     extraDockerOptions = [
       ''${network}''
     ];
     cmd = [
       "rpcdaemon"
       "--http.port=${rpcEth1Port}"
       "--http.addr=0.0.0.0"
       "--http.api=eth,net,web3,tg"
       ''--http.corsdomain=*''
       ''--http.vhosts=*''
        "--private.api.addr=turbo:9090"
      ];
      ports = [
        "0.0.0.0:8545:8545"
      ];
    };
  };
}
