# CI example. On a real machine bootstrap.sh writes ~/.config/dotfiles/machine.nix
# and rebuild.sh passes that directory in place of this one.
{
  role = "vm";
  user = "user";
  system = "x86_64-linux";
}
