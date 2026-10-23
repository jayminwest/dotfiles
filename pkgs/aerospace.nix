# AeroSpace from its release zip: nixpkgs lags, and the Homebrew cask is
# unreadable on Homebrew 6. modules/darwin-desktop.nix copies the app to
# /Applications (a stable path keeps its Accessibility grant).
# Bump: change version, then
#   nix store prefetch-file --unpack https://github.com/nikitabobko/AeroSpace/releases/download/v<version>/AeroSpace-v<version>.zip
{ stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "aerospace";
  version = "0.21.3-Beta";
  src = fetchzip {
    url = "https://github.com/nikitabobko/AeroSpace/releases/download/v${version}/AeroSpace-v${version}.zip";
    hash = "sha256-JHXtF3IKUbge7z2cMBi4L9IruiByNPCIKugLe4ymvys=";
  };
  dontFixup = true;
  installPhase = ''
    mkdir -p $out/Applications $out/bin
    cp -R AeroSpace.app $out/Applications/
    cp bin/aerospace $out/bin/
  '';
}
