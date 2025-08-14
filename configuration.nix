{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./hardware-custom.nix
      ./plymouth.nix
      ./jetbrains-toolbox-hacks.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = "options kvm_amd nested=1 snd_hda_intel power_save=0";
  boot.blacklistedKernelModules = [ "appletalk" "atm" "ax25" "batman-adv" "floppy" "l2tp_eth" "l2tp_ip" "l2tp_netlink" "l2tp_ppp" "netrom" "nfc" "rds" "rose" "sctp" "snd_pcsp" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-fe74e910-ac72-4f66-a54d-5cfd077b078d".device = "/dev/disk/by-uuid/fe74e910-ac72-4f66-a54d-5cfd077b078d";
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.UTF-8";
    LC_IDENTIFICATION = "cs_CZ.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "cs_CZ.UTF-8";
    LC_NAME = "cs_CZ.UTF-8";
    LC_NUMERIC = "cs_CZ.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "cs_CZ.UTF-8";
    LC_TIME = "cs_CZ.UTF-8";
  };

  # Disable X11 entirely
  services.xserver.enable = false;

  # KDE Plasma supremacy
  services = {
    desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Docker
  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.vojtech = {
    isNormalUser = true;
    description = "Vojtech";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" "docker" "dialout" ];
    packages = with pkgs; [
      thunderbird
      vscode
      orca-slicer
      slack
      teams-for-linux
      obs-studio
      qbittorrent
      nextcloud-client
      jetbrains-toolbox
      libreoffice-qt6-fresh
    ];
  };

  # Firefox.
  programs.firefox.enable = true;
  
  # ZSH
  programs.zsh.enable = true;

  # GTK consistency fix on KDE
  programs.dconf.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    curl
    kdePackages.kalk
    kdePackages.discover
    kdePackages.dolphin-plugins
    kdePackages.ffmpegthumbs
    kdePackages.filelight
    kdePackages.kio-admin
    kdePackages.kio-extras
    kdePackages.kio-zeroconf
    kdePackages.partitionmanager
    kdePackages.sddm-kcm
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.xdg-desktop-portal-kde
    kdePackages.powerdevil
    vlc
    git
    android-tools
    android-udev-rules
    pnpm
    rsync
    mkcert
    gnumake
    awscli2
    lsb-release
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    networkmanager-openvpn
    virt-manager
    imagemagick
    minicom
    solaar
  ];


  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    kwalletmanager
    xwaylandvideobridge
    plasma-browser-integration
  ];
  
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    fira
    ibm-plex
    inter
    roboto
  ];

  services.flatpak.enable = true;
  services.envfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  networking.firewall.enable = true;
  networking.hostName = "seth";
  networking.extraHosts = 
  ''
  '';
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  xdg.portal = {
    xdgOpenUsePortal = true;
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.OVMF.override {
        secureBoot = true;
        tpmSupport = true;
      }).fd];
    };
  };
};
 
  system.stateVersion = "25.05"; # Did you read the comment?
}
