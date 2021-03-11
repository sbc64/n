{config, ... }:
let
  network="--network=tg"; # docker network create medalla --driver bridge
  externalIp="136.244.116.42";
  rpcEth1Port="8545";
in
{
  docker-containers = {
    "turbo" = {
      image = "turbo-geth:latest";
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
     image = "turbo-geth:latest";
     extraDockerOptions = [
       ''${network}''
     ];
      volumes = [
        "/mnt/tg:/blockchain"
      ];
     cmd = [
       "rpcdaemon"
       "--chaindata=/blockchain"
       "--http.port=${rpcEth1Port}"
       "--http.addr=0.0.0.0"
       "--http.api=eth,net,web3"
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
