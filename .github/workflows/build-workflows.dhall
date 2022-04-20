let MaximizeBuildSpaceStep
    : Type
    = { uses : Text
      , `with` :
          { remove-dotnet : Bool
          , remove-android : Bool
          , remove-haskell : Bool
          , overprovision-lvm : Bool
          }
      }

let CheckoutStep
    : Type
    = { uses : Text, `with` : { fetch-depth : Natural } }

let InstallNixActionStep
    : Type
    = { uses : Text, `with` : { nix_path : Text } }

let CachixActionStep
    : Type
    = { uses : Text
      , `with` : { name : Text, extraPullNames : Text, authToken : Text }
      }

let Step
    : Type
    = < MaximizeBuildSpace : MaximizeBuildSpaceStep
      | Checkout : CheckoutStep
      | InstallNixAction : InstallNixActionStep
      | CachixAction : CachixActionStep
      >

let steps
    : List Step
    = [ Step.MaximizeBuildSpace
          { uses = "easimon/maximize-build-space@v5"
          , `with` =
            { remove-dotnet = True
            , remove-android = True
            , remove-haskell = True
            , overprovision-lvm = True
            }
          }
      , Step.Checkout { uses = "actions/checkout@v3", `with`.fetch-depth = 0 }
      , Step.InstallNixAction
          { uses = "cachix/install-nix-action@v17"
          , `with`.nix_path = "nixpkgs=channel:nixos-unstable"
          }
      , Step.CachixAction
          { uses = "cachix/cachix-action@v10"
          , `with` =
            { name = "thiagokokada-nix-configs"
            , extraPullNames = "nix-community"
            , authToken = "\${{ secrets.CACHIX_TOKEN }}"
            }
          }
      ]

in  { name = "build-and-cache"
    , on = [ "push", "workflow_dispatch" ]
    , jobs.build-linux = { runs-on = "ubuntu-latest", steps }
    }
