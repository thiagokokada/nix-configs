{ lib, ... }:

{
  options.meta = {
    fullname = lib.mkOption {
      description = "Main user full name.";
      type = lib.types.str;
      default = "Thiago Kenji Okada";
    };
    email = lib.mkOption {
      description = "Main e-mail.";
      type = lib.types.str;
      default = "thiagokokada@gmail.com";
    };
  };
}
