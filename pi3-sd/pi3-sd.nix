{ config, pkgs, lib, ... }:
# Install nixos-generate:
#nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
# Run with:
# nixos-generate -f sd-aarch64-installer --system aarch64-linux -c ./pi3-sd.nix -I nixpkgs=./nixpkgs
# raspberry pi needs to have a memory patch:
# git clone --depth=1 -b release-20.03 https://github.com/NixOS/nixpkgs
# cd nipkgs
# curl -L "https://github.com/NixOS/nixpkgs/pull/82718.patch" | git am
# Run the above in the nixpkgs submodule
# The above might not be needed once this gets merged
# https://github.com/NixOS/nixpkgs/pull/82718
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
  ];
  sdImage.compressImage = false;
  networking = {
    enableIPv6 = false;
    hostName = "pi3";
    interfaces.eth0.useDHCP = true;
    defaultGateway = {
      address = "192.168.1.254";
      interface = "wlan0";
    };
    interfaces = {
      wlan1 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.114";
            prefixLength = 24;
          }
        ];
      };
      wlan0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address="192.168.1.146";
            prefixLength = 24;
          }
        ];
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      unmanaged = [ "wlan0" "wlan1" ];
    };
    wireless = {
      # The interfaces wpa_supplicant will use. If empty, 
      # it will automatically use all wireless interfaces. 
      interfaces = [ "wlan1" "wlan0" ]; 
      userControlled.enable = true;
      userControlled.group = "wheel";
      networks = {
        "EE-Hub-9iPp" = {
          pskRaw = "86c32237c9c090fa4179777708847b790082291a2c3086bd7a23d44daefc8ae7";
        };
      };
    };
    firewall = {
      enable = false;
      allowedTCPPorts = [ 22 ];
    };
  };

  services = {
    sshd.enabled = true;
  };

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
  
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  boot = {
    extraModprobeConfig = ''
      options cf680211 ieee80211_regdom="GB"
    '';
    kernelPackages = pkgs.linuxPackages_rpi3;
    #kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };


  time.timeZone = "Europe/London";
  environment.systemPackages = with pkgs; [
     wget
     vim
     git # not gitFull because it takes too long
     nmap
  ];

  users = {
    users.root = {
      hashedPassword = "$7$UvihnRZQ94c$O3.dGzLep0aqSXcqQTnN4nVArLAHaCP.nq1zSc.N/cCW4oCWudNIFu84Vp81fNDK/u3nZXfJ6qji0/zFxn5V9/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0SSm2avOhdiDaQ38q/3NbtrakOFY8jLXcvA9Syb6Xx"
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.copySystemConfiguration = true; # ALWAYS HAVE THIS JUST INCASE
  system.stateVersion = "20.03"; # Did you read the comment?
}
