{ config, pkgs, lib, ... }:
let 
  tmuxConf = builtins.readFile "${pkgs.fetchurl {
    name = "tmux.conf";
    url = "https://raw.githubusercontent.com/sebohe/dotfiles/master/.tmux.conf";
    sha256 = "f265b99450cf3056bc248a99ed01e67957360674a71193f2a94c3d931ca76802";
  }}";
in
{
  
  time.timeZone = "Europe/London";
  environment.systemPackages = with pkgs; [
     wget
     curl
     traceroute
     vim
     htop
     starship
     git # not gitFull because it takes too long
  ];
  # Enable sshd at startup
  services.sshd.enable = true;
  systemd = {
    services = {
      sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
      wpa_supplicant = {
        enable = true;
        serviceConfig.Restart = "always";
        wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
      };
    };
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      interactiveShellInit = ''
        # z - jump around
        source ${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rupa/z/6586b61384cff33d2c3ce6512c714e20ea59bfed/z.sh";
          sha256 = "b3969a36b35889a097cd5a38e5e9740762f0e45f994b5e45991e2a9bdb2b8079";
        }}
        touch /root/.zshrc
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
        if [[ "$TMUX" == "" ]]; then
          WHOAMI=$(whoami)
          if tmux has-session -t $WHOAMI 2>/dev/null; then
            tmux -2 attach-session -t $WHOAMI
          else
              tmux -2 new-session -s $WHOAMI
          fi
        fi
      '';
      promptInit = "";
    };
    tmux = {
      enable = true;
      extraConfig = tmuxConf;
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.root = {
      hashedPassword = "$6$UvihnRZQ94c$O3.dGzLep0aqSXcqQTnN4nVArLAHaCP.nq1zSc.N/cCW4oCWudNIFu84Vp81fNDK/u3nZXfJ6qji0/zFxn5V9/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0SSm2avOhdiDaQ38q/3NbtrakOFY8jLXcvA9Syb6Xx"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+ZACqjP1HxwU8LbyFXObeDOItVrrG8aPw9GQ+E4LlR Ute@MacBook-Pro-4"
      ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system = {
    stateVersion = "20.03"; # Did you read the comment
    copySystemConfiguration = true;
  };
}

