{ pkgs ? import <nixpkgs> {} }:

let
  #eval = pkgs.lib.evalModules {
  #  modules = [ ./modules/srcds.nix ];
  #};
  eval = pkgs.lib.evalModules {
    specialArgs = {inherit pkgs;};
    modules = [ ./modules/srcds (_: {_module.check = false;}) ];
  };

  cleanEval = pkgs.lib.filterAttrsRecursive (n: v: n != "_module") eval;
in pkgs.nixosOptionsDoc {
  inherit (cleanEval) options;
}
