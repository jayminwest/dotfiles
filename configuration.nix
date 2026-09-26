{ config, user, ... }:

{
  # Determinate Nix manages the Nix daemon itself, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
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
    screencapture.location = "/Users/${user}/Pictures/Screenshots";
  };

  # Generated Brewfile at a stable path, for `brew-drift`.
  environment.etc."Brewfile".text = config.homebrew.brewfile;

  nix-homebrew = {
    enable = true;
    inherit user;
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
    brews = [
      # container stack
      "colima"
      "docker"
      "docker-compose"
      "docker-credential-helper"
      # background services
      "ollama"
      "syncthing"
      "tailscale"
      # macOS integration
      "pinentry-mac"
      "terminal-notifier"
      # Metal-optimized
      "whisper-cpp"
      # kota-voice mic capture (provides `rec`)
      "sox"
      # Swift toolchain
      "swiftlint"
      "swiftformat"
      "xcodegen"
      "periphery"
      # misc
      "herdr"
      "watch"
    ];
    casks = [
      "wezterm"
      "hammerspoon"
      "raycast"
      "tailscale-app"
      "cmux"
      "mark-text"
      "zettlr"
      "brave-browser"
    ];
  };
}
