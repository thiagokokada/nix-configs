{ fetchpatch, ... }:
[
  # https://github.com/NixOS/nixpkgs/pull/363922
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/commit/ae6664cc5110afc4aa214c1bd9013899f6324a07.patch";
    hash = "sha256-H7RXLGDwtWtLeXfrMVSd0Mab89JNoqhumKu/dE3lqVc=";
  })
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/commit/43e6aa5bd29e0a330462127b96c694392291bd49.patch";
    hash = "sha256-GirvMkd5T1dKDxaQrWWAOqTtSLvHzd7+GhjzYvedI5c=";
  })
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/commit/d4c1d6c482f920bbd070304ed573631339258f37.patch";
    hash = "sha256-iimCxs7LvJWrFTGWTeFvMzguf0s3ZKRfJfB2hBn0qFQ=";
  })
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/commit/14ab7a484d2c044d344aa2a41072e34f531515e8.patch";
    hash = "sha256-8SQUWkhBkdq7IA7Ln6Z9YMu0LqkiZy9PGHcppEYHwjM=";
  })
  (fetchpatch {
    url = "https://github.com/NixOS/nixpkgs/commit/c27b1c401ae659d20e4ed5bd6a50d31f7872fdce.patch";
    hash = "sha256-eYhDc4LbpGxk7nvpghivfYYXuZ9Goq9Sf63hy75HItE=";
  })
]
