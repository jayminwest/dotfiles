{
  description = "jayminwest's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Linux VMs: same release, the channel Hydra builds (and caches) for Linux.
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # This machine: ~/.config/dotfiles/machine.nix, written by bootstrap.sh and
    # passed in by rebuild.sh (--override-input). The stub is the CI example.
    machine = { url = "path:./stub/machine"; flake = false; };
    # Private overlay: ~/sync/dotfiles-local, passed in by rebuild.sh when it
    # exists. The stub adds nothing. See AGENTS.md.
    private = { url = "path:./stub/private"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-linux, nix-darwin, home-manager, nix-homebrew, machine, private }:
    let
      lib = nixpkgs.lib;

      # What each role adds on top of modules/home/core.nix (every machine).
      roles = {
        desktop = { darwin = [ ./modules/darwin.nix ./modules/darwin-desktop.nix ]; home = [ ./modules/home/mac.nix ./modules/home/desktop.nix ]; };
        server = { darwin = [ ./modules/darwin.nix ]; home = [ ./modules/home/mac.nix ]; };
        vm = { darwin = [ ]; home = [ ./modules/home/linux.nix ]; };
      };

      # machine: { role, user, system, host ? role, home ? standard for the OS }
      norm = m: {
        host = m.role;
        home = (if lib.hasSuffix "darwin" m.system then "/Users/" else "/home/") + m.user;
      } // m;
      overlay = m: import "${private}/default.nix" { machine = m; };
      herdrOverlay = final: prev: { herdr = final.callPackage ./pkgs/herdr.nix { }; };

      mkDarwin = m0:
        let
          m = norm m0;
          priv = overlay m;
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = { machine = m; user = m.user; };
          modules = roles.${m.role}.darwin ++ (priv.darwin or [ ]) ++ [
            { nixpkgs.hostPlatform = m.system; nixpkgs.overlays = [ herdrOverlay ]; }
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # A real file where home-manager wants a link is moved aside, not fatal.
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { machine = m; };
              home-manager.users.${m.user}.imports =
                [ ./modules/home/core.nix ] ++ roles.${m.role}.home ++ (priv.home or [ ]);
            }
          ];
        };

      mkHome = m0:
        let
          m = norm m0;
          priv = overlay m;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-linux {
            system = m.system;
            config.allowUnfree = true;
            overlays = [ herdrOverlay ];
          };
          extraSpecialArgs = { machine = m; };
          modules = [ ./modules/home/core.nix ] ++ roles.${m.role}.home ++ (priv.home or [ ]);
        };

      this = import "${machine}/machine.nix";
      isDarwin = lib.hasSuffix "darwin" this.system;
      example = role: system: { inherit role system; user = "user"; };
    in
    {
      # `default` is this machine; ci-* build every role in check.sh and CI.
      darwinConfigurations = {
        ci-desktop = mkDarwin (example "desktop" "aarch64-darwin");
        ci-server = mkDarwin (example "server" "aarch64-darwin");
      } // lib.optionalAttrs isDarwin { default = mkDarwin this; };

      homeConfigurations = {
        ci-vm = mkHome (example "vm" "x86_64-linux");
      } // lib.optionalAttrs (!isDarwin) { default = mkHome this; };

      packages = lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ] (system:
        {
          herdr = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/herdr.nix { };
        } // lib.optionalAttrs (lib.hasSuffix "darwin" system) {
          # rebuild.sh runs this pinned darwin-rebuild, so a fresh Mac needs nothing else.
          darwin-rebuild = nix-darwin.packages.${system}.darwin-rebuild;
        });
    };
}
