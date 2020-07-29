with import <nixpkgs> { };
{}:
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
    lazydocker
    go_1_14
  ];
}
