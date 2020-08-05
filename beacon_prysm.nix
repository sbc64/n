{config, ... }:
let
  dataPath="/home/.eth2validators";
  network="--network=medalla"; # docker network create medalla --driver bridge
  externalIp="165.227.245.71";
in
{
  docker-containers = {
    "goerli" = {
      image = "ethereum/client-go:v1.9.18";
      extraDockerOptions = [
        ''${network}''
        ''-p=10.100.0.2:30303:30303''
        ''-p=10.100.0.2:30303:30303/udp''
      ];
      volumes = [
        "goerli:/blockchain"
      ];
      cmd = [
        "--goerli"
        "--nousb"
        "--datadir=/blockchain"
        "--syncmode=fast"
        "--http"
        "--http.port=80"
        "--http.addr=0.0.0.0"
        "--http.api=eth,net,web3"
        "--http.vhosts='*'"
        "--nat=extip:${externalIp}"
      ];
    };
    "beacon" = {
      image = "gcr.io/prysmaticlabs/prysm/beacon-chain:latest";
      extraDockerOptions = [
        ''${network}''
        ''-p=4000:4000''
        ''-p=127.0.0.1:3500:3500''
        ''-p=10.100.0.2:13000:13000''
        ''-p=10.100.0.2:12000:12000/udp''
      ];
      # Report bug that this doesn't work. Need to figure out why.
      # Test by removing a few ports. Notice that it always
      # works when only one port is present
      ports = [
          #"3500:3500"
          #"4000:4000"
          #"10.100.0.2:13000:130000"
          #"10.100.0.2:12000:12000/udp"
      ];
      volumes = [
        "beacon_prysm:/data"
      ];
      cmd = [
        "--datadir=/data"
        "--rpc-host=0.0.0.0"
        "--grpc-gateway-host=0.0.0.0"
        "--grpc-gateway-port=3500"
        "--p2p-host-ip=${externalIp}"
        "--monitoring-host=0.0.0.0"
        #"--http-web3provider=http://goerli"
      ];
    };
    "validator1" = {
      image = "gcr.io/prysmaticlabs/prysm/validator:latest";
      extraDockerOptions = [
        ''${network}''
      ];
      ports = [
        #''8081:8081''
      ];
      volumes = [
        "/root/eth2-ops/prysm_1:${dataPath}"
      ];
      cmd = [
        ''--wallet-dir=${dataPath}/prysm-wallet-v2''
        ''--passwords-dir=${dataPath}/prysm-wallet-v2-passwords''
        "--beacon-rpc-provider=beacon:4000"
        "--monitoring-host=0.0.0.0"
        "--monitoring-port=8081"
        ''--wallet-password-file=${dataPath}/password''
      ];
    };
    "validator2" = {
      image = "gcr.io/prysmaticlabs/prysm/validator:latest";
      extraDockerOptions = [
        ''${network}''
      ];
      ports = [
        #''8081:8081''
      ];
      volumes = [
        "/root/eth2-ops/prysm_2:${dataPath}"
      ];
      cmd = [
        ''--wallet-dir=${dataPath}/prysm-wallet-v2''
        ''--passwords-dir=${dataPath}/prysm-wallet-v2-passwords''
        "--beacon-rpc-provider=beacon:4000"
        "--monitoring-host=0.0.0.0"
        "--monitoring-port=8081"
        ''--wallet-password-file=${dataPath}/password''
      ];
    };
  };
}
