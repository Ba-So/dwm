{
  description = "dwm - dynamic window manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { localSystem = system; };
      in {
        packages = {
          dwm = pkgs.stdenv.mkDerivation {
            pname = "dwm";
            version = "6.4";
            src = self;

            nativeBuildInputs = [ pkgs.pkg-config ];

            buildInputs = with pkgs; [
              xorg.libX11
              xorg.libXinerama
              xorg.libXft
              xorg.libxcb
              freetype
              fontconfig
            ];

            preBuild = ''
              makeFlagsArray+=(
                "INCS=-I${pkgs.xorg.libX11.dev}/include -I${pkgs.freetype.dev}/include/freetype2"
                "LIBS=-L${pkgs.xorg.libX11}/lib -lX11 -lXinerama -lfontconfig -lXft -lX11-xcb -lxcb -lxcb-res"
              )
            '';

            makeFlags = [ "PREFIX=$(out)" ];
          };

          default = self.packages.${system}.dwm;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.dwm ];
        };
      });
}
