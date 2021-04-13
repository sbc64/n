{ config, pkgs, lib, ... }:
let 
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
      ohMyZsh = {
        enable = true;
      };
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
          sha256 = "1jc0sj84rz7pqb81qjn0vmdf695acxds417m2whn2zk5vkqq0dqf";
        }}"
      '';
      promptInit = "";
    };
    tmux = {
      enable = true;
      extraConfig = builtins.readFile "${pkgs.fetchurl {
        name = "tmux.conf";
        url = "https://raw.githubusercontent.com/sebohe/dotfiles/master/.tmux.conf";
        sha256 = "0iskawnk35b9ka032jbn3bhbncajwqhv6xl294b113z79w1pvv90";
      }}";
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

