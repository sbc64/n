# remember to change the function call
# of /etc/nixos/configutaion to
# { pkgs, config, ... }: {
# to allow for this import vvvvvv to work
{pkgs, useZsh ? false, ...}:
let
  sshPort=59743;
  swarmMetricsPort = 9323;
  dockerbip="172.18.0.1";
in {

  imports = [
  ];

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ sshPort 80 443 ];
    };
  };

  services = {
    do-agent.enable = false;
    openssh = {
      passwordAuthentication = false;
    };
  };
  environment.systemPackages = with pkgs; [ 
    vim git neovim htop curl wget gnumake42 fd ripgrep starship jq
  ];
  users.defaultUserShell = if useZsh then pkgs.zsh else pkgs.bash;
  programs = {
    zsh = {
      ohMyZsh = {
        enable = useZsh;
      };
      enable = useZsh;
      enableCompletion = true;
      autosuggestions = {
        enable = true;
        highlightStyle = "fg=6";
        strategy = "match_prev_cmd";
      };
      interactiveShellInit = ''
        # z - jump around
        source ${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rupa/z/6586b61384cff33d2c3ce6512c714e20ea59bfed/z.sh";
          sha256 = "b3969a36b35889a097cd5a38e5e9740762f0e45f994b5e45991e2a9bdb2b8079";
        }}
        source "${pkgs.fetchurl {
          name = "zshrc";
          url = "https://raw.githubusercontent.com/sebohe/dotfiles/8a6370cea1e39285dbc2909fa9fb51d1a3329fed/.zshrc";
          sha256 = "0e3780f1dc657e612117f504a25b67aa24e35addc04a1cd0c2f7fc4c90d480c9";
        }}"
      '';
      promptInit = "";
    };
    tmux = {
      enable = useZsh;
      extraConfig = builtins.readFile "${pkgs.fetchurl {
        name = "tmux.conf";
        url = "https://raw.githubusercontent.com/sebohe/dotfiles/master/.tmux.conf";
        sha256 = "6a1bba3ead2477f387a18bcae1049dbfd309d8ace064c73cfd4b6bf1efdc2a24";
      }}";
    };
  };
  # Docker swarm
  networking.firewall.interfaces = {
      "docker_gwbridge".allowedTCPPorts = [ swarmMetricsPort ];
  };
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    enableOnBoot = true;
    autoPrune.enable = true;
    extraOptions = ''--metrics-addr=${dockerbip}:${toString swarmMetricsPort} --experimental --bip=${dockerbip}/16'';
  };
  systemd.services.init-swarm = {
    enable = true;
    description = "Init Docker swarm";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    script = ''
      IP=$(${pkgs.iproute}/bin/ip route get 1.1.1.1 | cut -f 7 -d ' ')
      ${pkgs.docker}/bin/docker swarm init --advertise-addr=$IP || true
    '';
    serviceConfig.Type="oneshot";
  };
}
