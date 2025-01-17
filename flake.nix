{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    {
      nixosModules = rec {
        srcds = (import ./modules).srcds;
        default = srcds;
      };
      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ];
      };
    };
}
