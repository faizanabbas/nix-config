{
  description = "Faizan's unified macOS & WSL Nix config";

  inputs = {
    # Get official Nix packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Manage user configs
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Manage macOS system settings
    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative homebrew management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    {
      self,
      darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      # Shared helper to handle different architectures
      mkSystem =
        {
          system,
          user,
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        if system == "aarch64-darwin" then
          # macOS configuration (system-level config + home-manager)
          darwin.lib.darwinSystem {
            inherit system;
            specialArgs = { inherit inputs user; };
            modules = [
              ./darwin.nix
              nix-homebrew.darwinModules.nix-homebrew
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${user} = import ./common.nix;
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          }
        else
          # Linux/WSL configuration (home-manager standalone)
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs user; };
            modules = [
              ./linux.nix
              ./common.nix
            ];
          };
    in
    {
      darwinConfigurations."mac" = mkSystem {
        system = "aarch64-darwin";
        user = "faizanabbas";
      };

      homeConfigurations."wsl" = mkSystem {
        system = "x86_64-linux";
        user = "faizan";
      };
    };
}
