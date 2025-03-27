{ lib, ... }:

{
  /*
    Recursively merge a list of attrsets into a single attrset.

    The result is the same as `foldl recursiveUpdate { }`, but the performance
    is better for large inputs.

    nix-repl> recursiveMergeAttrsList [ { a = "foo"; } { b = "bar"; } ];
    { a = "foo"; b = "bar"; }
    nix-repl> recursiveMergeAttrsList [ { a.b = "foo"; } { a.c = "bar"; } ]
    { a = { b = "foo"; c = "bar"; }; }
  */
  recursiveMergeAttrsList =
    list:
    let
      # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
      # Type: Int -> Int -> Attrs
      binaryMerge =
        start: end:
        # assert start < end; # Invariant
        if end - start >= 2 then
          # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
          # The invariant is satisfied because each half will have at least 1 element
          lib.recursiveUpdate (binaryMerge start (start + (end - start) / 2)) (
            binaryMerge (start + (end - start) / 2) end
          )
        else
          # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
          lib.elemAt list start;
    in
    if list == [ ] then
      # Calling binaryMerge as below would not satisfy its invariant
      { }
    else
      binaryMerge 0 (lib.length list);
}
