# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "odin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    consoleUseXkbConfig = true;
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    bash
    zsh
    ethtool
    nox
    ntp
    pciutils
    terminator
    tmux
    powertop
    openssh
    dmidecode
    bluez-tools
    # not necessary
    #xorg.xbacklight
    psmisc
    which
    avahi
    acpitool
    wget
    chromium
    firefox
    # per-user install "nix-env -i thunderbird"
    #thunderbird
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.extraCommands = ''
  #  iptables -A INPUT -p icmp -j ACCEPT
    iptables -F INPUT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 129.88.31.0/24 -j ACCEPT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 129.88.160.0/24 -j ACCEPT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 129.88.34.193/32 -j ACCEPT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 129.88.56.0/25 -j ACCEPT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 129.88.71.0/27 -j ACCEPT
    iptables -A INPUT -p tcp --match tcp --dport 22 --source 88.187.216.213/32 -j ACCEPT
  '';

  # Set common environment variables
  environment.variables.EDITOR = "vim";
 
  nixpkgs.config = {

    allowUnfree = true;

    # Enable browsers plugins
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
      jre = true;
    };
    chromium = {
      enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
      enablePepperPDF = true;
      jre = true;
    };

  };


  # List services that you want to enable:

#
#  # Enable docker virtualization
#  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  # For network printing
    services.avahi.enable = true;
    services.printing.browsing = true;
    services.printing.browsedConf = ''
      BrowseRemoteProtocols cups
      BrowsePoll print.imag.fr:631
    '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # NTP
  services.ntp.enable = true;
  services.ntp.servers = [ "ntp.u-ga.fr" "ntp2.u-ga.fr" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
#  #services.xserver.videoDrivers = [ "modesetting" "intel" ];
#  services.xfs.enable = true;
#  fonts.enableFontDir = true;
  services.xserver.layout = "fr";
  services.xserver.xkbVariant = "latin9";
  services.xserver.xkbOptions = "eurosign:e";
#  # synaptics not required for Gnome3 and conflict libinput in KDE
#  services.xserver.synaptics.enable = true;
#  services.xserver.synaptics.twoFingerScroll = true;
  services.xserver.exportConfiguration = true;
#  services.xserver.displayManager.sessionCommands = ''
#    # Start network manager applet
#    #${pkgs.networkmanagerapplet}/bin/nm-applet &
#    # Make the Meta key act into KDE like into Gnome
#    ksuperkey -e "Super_L=Control_L|F8" 
#    '';

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  # Enable the Gnome Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Enable network manager
  networking.networkmanager.enable = true;

  # Enable parallel build
  nix.maxJobs = 8 ;

  # 
  nix.useSandbox = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  programs.bash = {
    enableCompletion = true;
  };

  # Make sure I can use "openvpn" without entering my password
  security.sudo.configFile =
  ''
    henriot odin = (root) NOPASSWD: ALL
  '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
