# Empty private overlay. A real one (~/sync/dotfiles-local/default.nix) takes
# { machine } and returns { darwin = [ nix-darwin modules ]; home = [ home-manager modules ]; }.
{ machine }: { }
