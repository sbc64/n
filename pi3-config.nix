{ config, pkgs, lib, ... }:
{
  imports = [ /etc/nixos/hardware-configuration.nix ];
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
  };
  time.timeZone = "Europe/London";
  systemd.services = {
    sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
    wpa_supplicant = {
      enable = true;
      serviceConfig.Restart = "always";
      wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
    };
  };
  environment.systemPackages = with pkgs; [
     wget
     vim
     starship # try to remove this exta trust. Just use ZSH themes
     git # not gitFull because it takes too long
     lsd
     tmux
  ];

  services = {
    openssh.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      interactiveShellInit = ''
        # z - jump around
        source ${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/rupa/z/6586b61384cff33d2c3ce6512c714e20ea59bfed/z.sh";
          sha256 = "b3969a36b35889a097cd5a38e5e9740762f0e45f994b5e45991e2a9bdb2b8079";
        }}
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      '';
      promptInit = "";
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.root = {
      hashedPassword = "$6$UvihnRZQ94c$O3.dGzLep0aqSXcqQTnN4nVArLAHaCP.nq1zSc.N/cCW4oCWudNIFu84Vp81fNDK/u3nZXfJ6qji0/zFxn5V9/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0SSm2avOhdiDaQ38q/3NbtrakOFY8jLXcvA9Syb6Xx"
      ];
    };
  };

  networking = {
    enableIPv6 = false;
    hostName = "pi3";
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };

    interfaces = {
      eth0 = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address="1.1.1.2";
            prefixLength = 24;
          }
        ];
      };
      wlan0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.114";
            prefixLength = 24;
          }
        ];
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "20.03"; # Did you read the comment
    copySystemConfiguration = true;
  };
}
