{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tim = {
    initialPassword = "password";
    isNormalUser = true;
    extraGroups = [ "wheel" "wireshark" "docker" "vboxusers" "libvirtd" "games" "gamemode" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #Obs
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
	  obs-vaapi
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
  	  waveform
	  obs-source-clone
	  obs-shaderfilter
	  obs-move-transition
        ];
      })
      firefox
      tree
      discord
      gnome-software
      swww
      nwg-drawer
      waybar
      waypaper
      swaybg
      exfatprogs
      gparted
      nodePackages_latest.nodejs
      gnome-disk-utility
      looking-glass-client
      qemu
      libguestfs #tool to modify vm
      guestfs-tools #tool to modify vm
      OVMFFull#enable secure boot for QEMU
      dnsmasq
      cpuset
      rofi
      prismlauncher
      pulseaudio
      gccgo# C compiler
      fzf #Fuzzy finder for term
      tlrc
      neofetch
      cmatrix
      findutils
      discord
      ripgrep #used with Telescope(neovim)
      gtk-layer-shell
      nvtopPackages.full
      mediawriter
      nmap
      #vagrant
      gh #git hub cli
      swaynotificationcenter
      rpcs3 #Ps3 emulator
      pcsx2 #PS2 emulator
      obsidian #Powerful Notes Application
      libsForQt5.kdenlive #Video Editor
      #packer #packaging tool. Used for metasploitable build
      keepass
      hyprlock#screen locking utility
      easyeffects
      openvpn
      lutris
      wineWowPackages.stable
      winetricks
      tor-browser
      burpsuite
      libsForQt5.okular
      anki
      distrobox
      libreoffice-fresh
      thunderbird
      nitrogen #X11 wallpaper gui
      jq #use with javascript responses over grep
      jqp #tui
      yq #use with yaml query
      gimp
      rawtherapee
      #ciscoPacketTracer8
      file-roller#GUI based decompression utility
      shotwell #import photos. issues with nvidia on wayland
      piper#configure keyboard buttons like logitech ghub
      libratbag#backend for piper
      zoom-us
      telegram-desktop
      lxappearance # configure the appearance of GTK themed apps
      heroic
      kdePackages.kcalc#kde calculator
      appimage-run
      flameshot
      vlc
      ranger #cli file manager
      speedtest-cli
      axel #file downloader by splitting download into multiple channelsf
      lsd #better version of ls command
      ffmpeg
      ncdu # analyze/manage disk usage
      tldr
      flowtime # work efficiently
      mousam # weather app
      teamspeak_client
      stacer # system monitor and cleaner
      wireguard-tools #tools for wireguard vpn
      tigervnc
      blueman
      coolercontrol.coolercontrol-gui
      bottles
      onedrive
      googleearth-pro
      stress #cpu memory stress test cli
      s-tui #stress-terminal UI monitoriing tool
      nemo-with-extensions #file explorer
      freecad
      remmina #rdp client
      kitty
      wlogout
      wofi
      teams-for-linux
      memos
      brave
      corefonts
      vistafonts
      moonlight-qt
      errands # to do list
      pdfarranger
      evtest
      joplin-desktop
      #corepack_18
      zoxide #a smarter version of cd (change directory)
      flutterPackages-source.stable
    ];
  };

}
