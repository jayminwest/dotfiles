# herdr (https://herdr.dev) from its release binaries; not in nixpkgs.
# Bump: change version, then for each asset
#   nix store prefetch-file https://github.com/herdrdev/herdr/releases/download/v<version>/herdr-<asset>
{ stdenvNoCC, fetchurl }:

let
  version = "0.9.5";
  assets = {
    aarch64-darwin = { name = "macos-aarch64"; hash = "sha256-+3fCIyoFqANUITgsiUOS9BdOTjihjkivPdApAVfDp+I="; };
    x86_64-darwin = { name = "macos-x86_64"; hash = "sha256-X7CpCOx/Z0Xj4kVziwa/rVbEY5HDkas8CVX76tAfE2k="; };
    aarch64-linux = { name = "linux-aarch64"; hash = "sha256-F9dTby2lCFlSNoDvJ53/ysjkojX05G/o2mwuxEFBiXw="; };
    x86_64-linux = { name = "linux-x86_64"; hash = "sha256-FNnovItKngEY13wyJm921GHwm0A0LrI3UpYL2J9Zkp0="; };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "herdr";
  inherit version;
  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-${asset.name}";
    inherit (asset) hash;
  };
  dontUnpack = true;
  # Keep the release binary byte-for-byte (stripping breaks the macOS signature).
  dontFixup = true;
  installPhase = "install -Dm755 $src $out/bin/herdr";
  meta.mainProgram = "herdr";
}
