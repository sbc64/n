{ pkgs }:
{
  commonPackages = with pkgs; [
     wget
     curl
     traceroute
     vim
     htop
     starship
     git # not gitFull because it takes too long
  ];
  workPackages = with pkgs; [
    neovim
  ];
}
