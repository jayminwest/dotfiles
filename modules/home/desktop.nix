# Desktop role (the Macs a human sits at): AeroSpace tiling.
{ config, ... }:

{
  home.file.".config/aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/home/.config/aerospace/aerospace.toml";
}
