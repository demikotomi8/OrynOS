{
  inputs,
  pkgs,
  username,
  hostname,
  system,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hosts/${hostname}/hardware-configuration.nix
    ./hosts/${hostname}/default.nix

    # Hardware Support
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  # --- 1. Home Manager Safety ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # <--- Prevents install errors
    extraSpecialArgs = {
      inherit inputs username hostname system;
    };
    users."${username}" = {
      imports = [
        ./home/${username}/${hostname}/default.nix
      ];
    };
  };
  
  # --- 3. CLI Superpowers (Comma) ---
  programs.nix-index-database.comma.enable = true;
  # Keeps the index updated automatically
  programs.command-not-found.enable = false; # Disable default to use nix-index

  # --- 4. Visual Stack ---
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember";
        user = "greeter";
      };
    };
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # System Basics
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "adbusers"];
    shell = pkgs.zsh;
  };

  # Extra fonts
  fonts.packages = with pkgs; [
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
    google-fonts
    noto-fonts
  ];

  system.stateVersion = "25.05";
}
