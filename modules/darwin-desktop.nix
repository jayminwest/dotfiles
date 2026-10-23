# System config for the Macs a human sits at (desktop role).
{ lib, pkgs, ... }:

let
  aerospace = pkgs.callPackage ../pkgs/aerospace.nix { };
in
{
  homebrew.taps = [ "felixkratz/formulae" ];
  homebrew.brews = [
    "felixkratz/formulae/borders"  # window borders, started by aerospace.toml
    "ollama"
    # Metal-optimized
    "whisper-cpp"  # Flick dictation
    "sox"          # mic capture (provides `rec`)
    # Swift toolchain
    "swiftlint"
    "swiftformat"
    "xcodegen"
    "periphery"
  ];
  homebrew.casks = [
    "homerow"
    "hammerspoon"
    "mark-text"
    "zettlr"
  ];

  # AeroSpace: the `aerospace` CLI on PATH, and the app copied to
  # /Applications when its version changes (never a store path: macOS ties
  # the Accessibility grant to the app's location).
  environment.systemPackages = [ aerospace ];
  system.activationScripts.postActivation.text = lib.mkAfter ''
    want="$(/usr/bin/defaults read ${aerospace}/Applications/AeroSpace.app/Contents/Info CFBundleShortVersionString)"
    have="$(/usr/bin/defaults read /Applications/AeroSpace.app/Contents/Info CFBundleShortVersionString 2>/dev/null || true)"
    if [ "$want" != "$have" ]; then
      echo "installing AeroSpace $want (was: ''${have:-none})"
      rm -rf /Applications/AeroSpace.app
      cp -R ${aerospace}/Applications/AeroSpace.app /Applications/
      chmod -R u+w /Applications/AeroSpace.app
    fi
  '';
}
