{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default =
        with pkgs;
        mkShell {
          packages = [
            zig
            rustc
            cargo
            aoc-cli
          ];
          shellHook = ''
            export JUST_UNSTABLE=1
          '';
        };
    };
}
