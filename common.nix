{ config, pkgs, lib, ... }:
let 
  tmuxConf = builtins.readFile "${pkgs.fetchurl {
    name = "tmux.conf";
    url = "https://raw.githubusercontent.com/sebohe/dotfiles/master/.tmux.conf";
    sha256 = "f265b99450cf3056bc248a99ed01e67957360674a71193f2a94c3d931ca76802";
  }}";
  secrets = import <secrets>;
in
{
  time.timeZone = "Europe/London";
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
    ohMyZsh.enable = true;
      enable = true;
      enableCompletion = true;
      interactiveShellInit = ''
        # z - jump around
        source ${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rupa/z/6586b61384cff33d2c3ce6512c714e20ea59bfed/z.sh";
          sha256 = "b3969a36b35889a097cd5a38e5e9740762f0e45f994b5e45991e2a9bdb2b8079";
        }}
        source "${pkgs.fetchurl {
          name = "zshrc";
          url = "https://raw.githubusercontent.com/sebohe/dotfiles/master/.zshrc";
          sha256 = "3ef0237c7f38a7c5fd6f3ad012ec5f764ad032e857904b6ec688f485abfbe715";
        }}"
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
      hashedPassword = secrets.common.pw;
      openssh.authorizedKeys.keys = secrets.common.ssh_keys;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system = {
    stateVersion = "20.03"; # Did you read the comment
    copySystemConfiguration = true;
  };
}

