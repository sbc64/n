# Use predictable interface names in stage-1 and stage-2.
# DOC: https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
#
# Tip: names that can be given using ID_NET_NAME_* envvars
# can be checked before hand with:
# udevadm test-builtin net_id /sys/class/net/*

{ pkgs, lib, config, ... }:
let udevNetSetupLinkRules = pkgs.writeTextFile {
    name = "80-net-setup-link.rules";
    destination = "/etc/udev/rules.d/80-net-setup-link.rules";
    text = ''
	SUBSYSTEM!="net", GOTO="net_setup_link_end"
	IMPORT{builtin}="path_id"
	ACTION!="add", GOTO="net_setup_link_end"
	IMPORT{builtin}="net_setup_link"
	SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="d0:37:45:6a:94:c3", KERNEL=="wlan*", NAME="wlan1", ATTR{dev_id}=="0x0", ATTR{type}=="1", ATTR{idVendor}=="2357", ATTR{idProduct}=="010c" 
	SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="b8:27:eb:5e:55:31", KERNEL=="wlan*", NAME="wlan0", ATTR{dev_id}=="0x0", ATTR{type}=="1"
	LABEL="net_setup_link_end"
    '';
  };
in
{
  networking.usePredictableInterfaceNames = true;

  boot.initrd = {
    extraUdevRulesCommands = ''
      cp -v -f ${pkgs.systemd}/lib/udev/rules.d/75-net-description.rules $out/
      cp -v -f ${udevNetSetupLinkRules}/etc/udev/rules.d/80-net-setup-link.rules $out/
    '';
  };

  # Only useful here in stage-2 if the device is removed and re-added
  # (eg. the network module is rmmod-ed then modprobe-d).
  # The stage-1 (or initrd) is only a pivot_root after all,
  # it does not reload the kernel, hence passing to stage-2
  # does not trigger ACTION=="add" for the net devices.
  #services.udev.packages = [
    # udevNetSetupLinkRules
  #];
}
