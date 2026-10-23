# System config for every Mac (desktop and server roles).
{ config, machine, ... }:

{
  # Determinate Nix manages the Nix daemon itself, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = machine.user;
  users.users.${machine.user}.home = machine.home;
  system.stateVersion = 6;

  # macOS defaults. Applied on every rebuild; delete a line to stop managing it.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      AppleShowAllExtensions = true;
    };
    trackpad.Clicking = true; # tap to click
    dock = {
      autohide = true;
      orientation = "right";
      tilesize = 39;
      show-recents = false;
      mru-spaces = false;       # don't reorder Spaces by recent use
    };
    finder = {
      ShowPathbar = true;
      ShowStatusBar = true;
      AppleShowAllFiles = true;  # show hidden files
      FXPreferredViewStyle = "Nlsv"; # list view
      FXDefaultSearchScope = "SCcf"; # search current folder
      _FXShowPosixPathInTitle = true;
    };
    screencapture.location = "${machine.home}/Pictures/Screenshots";
  };

  # Generated Brewfile at a stable path, for `brew-drift`.
  environment.etc."Brewfile".text = config.homebrew.brewfile;

  nix-homebrew = {
    enable = true;
    user = machine.user;
    # Adopt the pre-existing /opt/homebrew installation instead of failing;
    # keeps installed packages, replaces Homebrew's own core with the managed one.
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # "none": switches never remove anything, so ad-hoc `brew install`s survive.
    # The lists below are what a fresh machine gets; `brew-drift` (run after
    # every ./rebuild.sh) shows installed packages missing from them.
    # Never "zap": it also deletes app data (it wiped the Brave profile once).
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    # Things that belong in brew rather than Nix: launchd services,
    # macOS-integrated tools, Metal builds, and Swift tooling.
    # Every Mac gets these; roles and the private overlay append their own.
    brews = [
      # container stack
      "colima"
      "docker"
      "docker-compose"
      "docker-credential-helper"
      # background services
      "syncthing"
      "tailscale"
      # macOS integration
      "pinentry-mac"
      "terminal-notifier"
      # misc
      "watch"
    ];
    casks = [
      "wezterm"
      "tailscale-app"
      "cmux"
      "brave-browser"
    ];
  };
}
