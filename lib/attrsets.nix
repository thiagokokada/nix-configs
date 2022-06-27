{ lib, ... }:

{
  /* Recursively merge a list of attrsets into a single attrset.

    nix-repl> recursiveMergeAttrs [ { a = "foo"; } { b = "bar"; } ];
    { a = "foo"; b = "bar"; }
    nix-repl> mergeAttrsetsList [ { a.b = "foo"; } { a.c = "bar"; } ]
    { a = { b = "foo"; c = "bar"; }; }
  */
  recursiveMergeAttrs = builtins.foldl' lib.recursiveUpdate { };
}
