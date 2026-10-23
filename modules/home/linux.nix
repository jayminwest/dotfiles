# Linux VMs (vm role): standalone home-manager on a non-NixOS distro.
{ ... }:

{
  targets.genericLinux.enable = true;
  # `home-manager` on PATH (news, generations); rebuild.sh doesn't need it.
  programs.home-manager.enable = true;
}
