{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  #Virtualization
  #virtualisation.virtualbox.host.enable = true;
  #users.extraGroups.vboxusers.members = [ "tim" ];
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.guest.x11 = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  #virtualisation.spiceUSBRedirection.enable = true;
}
