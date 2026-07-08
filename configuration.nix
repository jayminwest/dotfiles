{ user, ... }:

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
  };

  nix-homebrew = {
    enable = true;
    inherit user;
    # Adopt the pre-existing /opt/homebrew installation instead of failing;
    # keeps installed packages, replaces Homebrew's own core with the managed one.
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # "zap": every switch removes any brew package/cask NOT listed below.
    # This is the whole point - the lists here are the source of truth.
    onActivation.cleanup = "zap";
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
      # Swift toolchain
      "swiftlint"
      "swiftformat"
      "xcodegen"
      "periphery"
      # misc
      "herdr"
      "rust"
      "watch"
    ];
    casks = [
      "wezterm"
      "hammerspoon"
      "cmux"
      "mark-text"
      "zettlr"
    ];
  };
}
