{
  description = "Oryn's NixOS Configuration";

  inputs = {
    # 1. Official Unstable Channel (Best for Hyprland/Gaming)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 3. Nix-Index (Command-not-found powers)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rycee-nurpkgs = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community Modules
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    nvix.url = "github:niksingh710/nvix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-index-database,
    nur,
    nix-flatpak,
    nixos-hardware,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "pilot";
    hostname = "nixos";

    # Package Config
    pkgsConfig = {
      allowUnfree = true;
    };

    pkgsOverlays = [
      nur.overlays.default
    ];

    # Arguments passed to every module
    sharedSpecialArgs = {
      inherit inputs username hostname system;
    };
  in {
    # 1. System Configuration
    nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = sharedSpecialArgs;
      modules = [
        ./configuration.nix

        # Modules injected directly here
        nix-flatpak.nixosModules.nix-flatpak
        nix-index-database.nixosModules.nix-index

        # Global Nixpkgs Config
        {
          nixpkgs.config = pkgsConfig;
          nixpkgs.overlays = pkgsOverlays;

          i18n.inputMethod.enabled = nixpkgs.lib.mkForce null;
        }
      ];
    };

    # 2. Standalone Home Manager Configuration
    homeConfigurations."${username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config = pkgsConfig;
        overlays = pkgsOverlays;
      };
    };
  };
}
