{ ... }:

# Functions without dependencies (e.g.: nixpkgs)
let
  inherit (builtins) elemAt foldl' head isAttrs length zipAttrsWith;

  # Extract functions from nixpkgs/lib/attrsets.nix, use it from there instead
  _recursiveUpdateUntil = pred: lhs: rhs:
    let f = attrPath:
      zipAttrsWith (n: values:
        let here = attrPath ++ [ n ]; in
        if length values == 1
          || pred here (elemAt values 1) (head values) then
          head values
        else
          f here values
      );
    in f [ ] [ rhs lhs ];

  _recursiveUpdate = _recursiveUpdateUntil (path: lhs: rhs: !(isAttrs lhs && isAttrs rhs));
in
rec {
  /* Recursively merge a list of attrsets into a single attrset.

    nix-repl> recursiveMergeAttrs [ { a = "foo"; } { b = "bar"; } ];
    { a = "foo"; b = "bar"; }
    nix-repl> mergeAttrsetsList [ { a.b = "foo"; } { a.c = "bar"; } ]
    { a = { b = "foo"; c = "bar"; }; }
  */
  recursiveMergeAttrs = foldl' _recursiveUpdate { };
}
