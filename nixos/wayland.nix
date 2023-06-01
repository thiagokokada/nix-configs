{ ... }:

{
  programs.sway = {
    # Make Sway available for display managers
    enable = true;
    # Remove unnecessary packages from system-wide install (e.g.: foot)
    package = null;
    extraPackages = [ ];
  };
}
