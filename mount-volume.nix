{ ... }:
let
  volumeName =  "/dev/disk/by-uuid/55cd6e07-3683-4a6e-b8ec-4679494121ff";
in
{
  fileSystems."/var/lib/docker/volumes" = {
    device = volumeName;
    fsType = "ext4";
  };
}
