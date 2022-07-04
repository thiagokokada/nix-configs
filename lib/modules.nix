{ lib, ... }:

{
  /* Like mkEnableOption, just enable the option by default instead */
  mkDefaultOption = name: lib.mkEnableOption name // { default = true; };
}
