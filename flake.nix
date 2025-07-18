{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    niri-flake.url = "github:sodiboo/niri-flake";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    niri-flake,
    emacs-overlay,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      astra-rog = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ({ config, pkgs, ... }: {
           nixpkgs.overlays = [ emacs-overlay.overlays.emacs ];
           environment.systemPackages = [
           ((pkgs.emacsPackagesFor pkgs.emacs-git-pgtk).emacsWithPackages (epkgs: [
             epkgs.vterm
             (epkgs.treesit-grammars.with-grammars (grammars: [
                                                    grammars.tree-sitter-kdl
             ]))
           ]))
           ];
           })
        home-manager.nixosModules.default
        niri-flake.nixosModules.niri
        ./nixos/configuration.nix
        ./nixos/astra/configuration_astra.nix
        ];
      };
      ccdesktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ({ config, pkgs, ... }: {
           nixpkgs.overlays = [ emacs-overlay.overlays.emacs ];
           environment.systemPackages = [
           ((pkgs.emacsPackagesFor pkgs.emacs-git-pgtk).emacsWithPackages (epkgs: [
             epkgs.vterm
             (epkgs.treesit-grammars.with-grammars (grammars: [
                                                    grammars.tree-sitter-kdl
             ]))
           ]))
           ];
           })
        home-manager.nixosModules.default
        niri-flake.nixosModules.niri
        ./nixos/configuration.nix
        ./nixos/ccdesktop/configuration_ccdesktop.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "cc@astra-rog" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
        ];
      };
      "cc@ccdesktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
        ];
      };
    };
  };
}
