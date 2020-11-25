with import <nixpkgs> {};
let
  name = "eth1-node";
  composeFile = pkgs.writeText "docker-compose.yml" ''
    version: "3.8"
    volumes:
      ethereum:
      goerli:
    services:
      ethereum:
        image: ethereum/client-go:stable
        entrypoint:
          - geth
          - --nousb
          - --ipcdisable
          - --datadir=/blockchain
          - --syncmode=fast
          - --http
          - --http.port=8545
          - --http.addr=0.0.0.0
          - --http.api=eth,net,web3
          - --http.vhosts="*"
          - --cache=7500
        volumes:
          - ethereum:/blockchain
        ports:
          - target: 8545
            published: 8545
            protocol: tcp
            mode: host
          - target: 30303
            published: 30303
            protocol: tcp
            mode: host
          - target: 30303
            published: 30303
            protocol: udp
            mode: host
      goerli:
        image: ethereum/client-go:stable
        entrypoint:
          - geth
          - --goerli
          - --ipcdisable
          - --nousb
          - --datadir=/blockchain
          - --http
          - --http.port=8546
          - --http.addr=0.0.0.0
          - --http.api=eth,net,web3
          - --http.vhosts="*"
          - --port=30304
        volumes:
          - goerli:/blockchain
        ports:
          - target: 8546
            published: 8546
            protocol: tcp
            mode: host
          - target: 30304
            published: 30304
            protocol: tcp
            mode: host
          - target: 30304
            published: 30304
            protocol: udp
            mode: host
  '';
in
{
  systemd.services.init-swarm = {
    description = "Init Docker swarm";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    script = ''
      IP=$(${pkgs.iproute}/bin/ip route get 1.1.1.1 | cut -f 7 -d ' ')
      ${pkgs.docker}/bin/docker swarm init --advertise-addr=$IP || true
    '';
    serviceConfig = {
      Type="oneshot";
    };
  };
  systemd.services.${name} = {
    description = "Docker compose for ${name}";
    wantedBy = [ "multi-user.target" ];
    after = [ "init-swarm.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker}/bin/docker stack deploy -c ${composeFile} ${name}";
      Type="simple";
    };
  };
}
