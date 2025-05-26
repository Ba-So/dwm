{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self, 
    nixpkgs, 
    ... 
    }: let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem = lib.genAttrs systems;
      pkgsFor = eachSystem (system:
        import nixpkgs {
          localSystem.system = system;
          overlays = [self.overlays.dwm];
        });
      gitRev = self.rev or self.dirtyRev or null;
    in {

      packages = eachSystem (system: {
        inherit (pkgsFor.${system}) dwm;
        default = self.packages.${system}.dwm;
      });
      
      overlays = {
        dwm = final: prev: {
          dwm = final.callPackage ./default.nix {inherit gitRev;};
        };
        default = self.overlays.dwm;
      };
    };
}
