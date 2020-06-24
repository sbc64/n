{ config, pkgs, lib, ... }:
let 
  tmuxConf = ''# Set XTerm key bindings
setw -g xterm-keys on

# Set colors
set -g default-terminal "xterm-256color"

# Count sessions start at 1
set -g base-index 1

# Use vim bindings
setw -g mode-keys vi

# Set default shell
set -g default-shell $SHELL

# Enable mouse mode (tmux 2.1 and above)
set -g mouse on

# Windows and panes creations
bind c new-window -c "#{pane_current_path}"
bind \ split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# switch panes using Alt-arrow without prefix
bind -n M-h select-pane -L
bind -n M-l select-pane -R
bind -n M-k select-pane -U
bind -n M-j select-pane -D

# pane resizing using arrow keys
bind-key -n M-Left resize-pane -L
bind-key -n M-Right resize-pane -R
bind-key -n M-Up resize-pane -U
bind-key -n M-Down resize-pane -D

# Select windows using Alt + <number>. Like firefox
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9

# remap prefix from 'C-b' to 'C-a'
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# bind-key -T copy-mode-vi v send-keys -X begin-selection
# For binding 'y' to copy and exiting selection mode
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -sel clip -i'

# dev mode
unbind D

# Justify windows to left
set-option -g status-justify centre

# Place status bar on top
set-option -g status-position top

# Clean status bar
set -g status-left ""
set -g status-right ""

# Set status bar colors
set -g status-bg black
set -g status-fg white
set -g status-interval 10
set -g status-left-length 70
set -g status-right-length 60
set -g status-interval 1
set -g status-right '#[fg=white]%H:%M'
set -g status-left "#[fg=yellow]#(curl ipecho.net/plain;echo)@#(hostname)"
set -sg escape-time 0;
'';
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

