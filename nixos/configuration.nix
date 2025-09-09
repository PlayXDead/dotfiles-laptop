{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user.nix
      ./secrets.nix
      ./virtualization.nix
      ./environment.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  boot.loader = {
    efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot"; # ← use the same mount point here.
    };
    grub = {
       efiSupport = true;
       #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
       device = "nodev";
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #Extra Kernel Modules - v4l2loopback
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  networking.hostName = "AWildPlaybox"; #define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Detroit";
  #services.automatic-timezoned.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
    console = {
    font = "Lat2-Terminus16";
     #keyMap = "us";
     useXkbConfig = true; # use xkbOptions in tty.
   };

  #Load GPU DRIVERS Early
  boot.initrd.kernelModules = [
    "nvidia"
  ];

  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [
    "nvidia"
    "nvidia-vaapi-driver"
  ];

  #Improve memory performance for games & windows applications using Wine/Proton
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  powerManagement.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.udev.packages = [
    pkgs.openrgb
    pkgs.via
  ];
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  hardware.keyboard.qmk.enable = true;


  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
         governor = "power";
         energy_performance_preference = "power";
         turbo = "auto";
      };
      charger = {
         governor = "performance";
         energy_performance_preference = "performance";
         turbo = "always";
      };
    };
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  #Nvidia Drivers
  hardware.nvidia = {

  # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
   
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    #powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      sync.enable = true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId ="PCI:01:00:0";
    };
  };

  hardware.graphics = {
  ## radv: an open-source Vulkan driver from freedesktop
    enable = true;
  };

  # Configure keymap in X11
   services.xserver.xkb.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    cups-pdf = {
      enable = true;
      instances.pdf.settings = {
        Out = "/home/tim/Work/prints";
      };
    };
  };

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.support32Bit = true;
  
  # Enable Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Disable Root User Password
  users.users.root.hashedPassword = "!";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    nano
    pavucontrol
    alacritty
    networkmanagerapplet
    btop
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    libva
    gitFull
    usbutils
    coreutils-full
    udiskie # auto mount usb devices
    zip
    unzip
    wireshark
    bat
    eza
    playerctl #media controller necessary to add keyboard media functionality
    nix-index # tool to help find things such as config files on nix. ex: nix-locate polybar/config
    busybox # list of critical system tools.
    #polkit_gnome
    lxqt.lxqt-policykit#polkit agent
    snort # intrusion detection
    via
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "googleearth-pro-7.3.6.10201"
  ];

  #neovim
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    enable = true;
    defaultEditor = true;
  };


  #Whitelist Unfree
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  #Fonts
  fonts.packages = with pkgs; [
    fwknop #Single Packet Authorization (and Port Knocking) server/client
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  fonts.fontDir.enable = true;

  #Java
  programs.java.enable = true; 

  #Steam Stuff
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.steam.gamescopeSession.enable = true;

  programs.gamemode.enable = true;

  services.teamviewer.enable = true;
  

    # List services that you want to enable:
  nix.settings.auto-optimise-store = true;

  services.ollama = {
    enable = true;
    loadModels = [ 
      gemma3:latest
    ];
    acceleration = "cuda";
  };


  services.open-webui = {
    enable = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
      };
    };

  #Flatpak
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    #extraPortals = [ 
    #pkgs.xdg-desktop-portal-kde
    #  ];
    wlr.enable = true;
    xdgOpenUsePortal = true;
  };

    #wireshark
  programs.wireshark.enable = true;

  #Authenticator
  systemd = {
  user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  services.udisks2.enable = true;#DBus service that allows applications to query and manipulate storage devices.

  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  #services.undervolt = {
  #  enable = true;
  #  coreOffset = -40;
  #};

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
