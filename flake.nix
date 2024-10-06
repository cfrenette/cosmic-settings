{
  inputs = {
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, nixos-cosmic, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
    in
    {
      devShells.${system}.default = with pkgs; nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = [
          (
            nixos-cosmic.packages.${system}.cosmic-settings.overrideAttrs (
              oldAttrs: {
                src = ./.;
                # cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
                #   name = "cosmic-settings-development";
                #   src = ./.;
                #   cargoSha256 = "";
                # };
                cargoHash = "";
              }
            )
          )
          (
            rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
            }
          )
          rust-analyzer
        ];
      };
    };
}

