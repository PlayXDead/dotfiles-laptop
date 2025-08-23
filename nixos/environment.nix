{ config, pkgs, inputs, ... }:

{
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  #For i3
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Enable Desktop Environment
  services = {
    xserver = {
      displayManager.gdm = {
        enable = true;
      };
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          i3status
	        i3lock
	        i3blocks
	        autotiling
	        polybar
	        dunst #notification daemon
	        libnotify #send notifications to dunst
          picom
	        tint2
        ];
      };  
    };
  };  

  #default session
  #services.displayManager.defaultSession = "none+i3";

  #kanshi systemd service. adds hot swap functionality with monitors
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };  

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #apply default themes to wayland (KDE)
  programs.dconf.enable = true;
  qt.platformTheme = "gnome"; qt.style = "breeze";
}

