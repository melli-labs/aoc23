{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    roc = {
      url = "github:roc-lang/roc";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      # see: https://github.com/NixOS/nix/issues/5790
      inputs.flake-utils.inputs.systems.follows = "systems";
    };
  };

  outputs = { self, systems, nixpkgs, devshell, roc, rust-overlay }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs
          (import systems)
          (
            system: f {
              roc = roc.packages.${system}.default;
              pkgs = import nixpkgs {
                inherit system;
                overlays = [ devshell.overlays.default (import rust-overlay) ];
              };
            }
          );
    in
    {
      devShells = eachSystem ({ pkgs, roc }: {
        default =
          let
            rust-toolchain = pkgs.rust-bin.selectLatestNightlyWith
              (toolchain: toolchain.default.override {
                extensions = [ "rust-src" "rust-analyzer" ];
              });
          in
          pkgs.devshell.mkShell {
            motd = "";
            packages = with pkgs; [
              # Python
              (python311.withPackages (p: with p; [ black isort ipython ]))
              # Roc
              roc
              # Rust
              rust-toolchain
              bacon
              cargo-expand
              cargo-sort
              evcxr
            ];
          };
      });
    };
}
