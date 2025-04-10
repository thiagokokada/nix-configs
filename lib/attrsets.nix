{ lib, ... }:

rec {
  # Recursively merge a list of attrsets into a single attrset.
  #
  # nix-repl> recursiveMergeAttrs [ { a = "foo"; } { b = "bar"; } ];
  # { a = "foo"; b = "bar"; }
  # nix-repl> recursiveMergeAttrs [ { a.b = "foo"; } { a.c = "bar"; } ]
  # { a = { b = "foo"; c = "bar"; }; }
  recursiveMergeAttrs = builtins.foldl' lib.recursiveUpdate { };

  # Builds a map from <attr>=value to <attr>.<system>=value for each system.
  eachSystem =
    systems: f:
    lib.foldAttrs lib.mergeAttrs { } (map (s: lib.mapAttrs (_: v: { ${s} = v; }) (f s)) systems);

  eachDefaultSystem = eachSystem [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  # Call function to each directory inside a dir.
  #
  # Will return a list of attrs.
  mapDir =
    f: dir:
    (lib.mapAttrsToList (curDir: type: lib.optionalAttrs (type == "directory") (f curDir)) (
      builtins.readDir dir
    ));

  # Translate the keys from a attrset.
  translateKeys = trans: attrset: lib.mapAttrs' (n: v: lib.nameValuePair (trans.${n} or n) v) attrset;
}
