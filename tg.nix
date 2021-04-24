{config, pkgs ? <nixpkgs>, ... }:
let
  network="--network=tg"; # docker network create medalla --driver bridge
  externalIp="136.244.116.42";
  rpcEth1Port="8545";
  image="sebohe/turbo-geth";
  tag="v2021.04.04";
  tg = pkgs.dockerTools.pullImage {
    imageName = image;
    finalImageTag = tag;
    imageDigest = "sha256:383d154df5ea3804baae6052ac33f34bdfe07ff0027da66c2f7b1462af3ae611";
    sha256 = "000003zq2v6rrhizgb9nvhczl87lcfphq9601wcprdika2jz7qh8";
  };
in
{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    "turbo" = {
      image = tg.imageName+":"+tag;
      extraOptions = [
        ''${network}''
        ''-p=10.1.0.10:30303:30303''
        ''-p=10.1.0.10:30303:30303/udp''
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
     extraOptions = [
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
