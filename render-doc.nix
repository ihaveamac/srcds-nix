{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
  eval = lib.evalModules {
    specialArgs = {inherit pkgs;};
    modules = [
      ./modules/srcds/default.nix
      (_: {_module.check = false;})
      ./support/fake-steam.nix
    ];
  };

  cleanEval = lib.filterAttrsRecursive (n: v: n != "_module") eval;
  sourceLinkPrefix = "https://github.com/ihaveamac/srcds-nix/blob/main";
  prefix = ./.;
in nixosOptionsDoc {
  inherit (cleanEval) options;

  # taken from:
  # https://github.com/Jovian-Experiments/Jovian-NixOS/blob/a86d9cf841eff8b33a05d2bf25788abd8e018dbd/support/docs/lib/options-doc.nix#L15
  transformOptions = opt: opt // {
    declarations = map (decl:
      if lib.hasPrefix (toString prefix) (toString decl)
      then
        let
          subpath = lib.removePrefix "/" (lib.removePrefix (toString prefix) (toString decl));
        in
        { url = "${sourceLinkPrefix}/${subpath}"; name = subpath; }
      else decl
    ) opt.declarations;
  };
}
