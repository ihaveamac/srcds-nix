{ buildFHSEnv, writeShellScript }:

# the fhs runner is based on:
# https://github.com/NixOS/nixpkgs/blob/de1864217bfa9b5845f465e771e0ecb48b30e02d/pkgs/by-name/st/steam/package.nix

# this uses a patched curl that I think only TF2 needs
let
  allPkgs = pkgs: with pkgs; [
    glibc
    #ncurses5
    ( curlWithGnuTls.overrideAttrs (final: prev: {
      patches = (if prev ? patches then prev.patches else []) ++ [ ./curl-symbol-downgrade.patch ];
    } ) )
  ];
in buildFHSEnv {
  name = "srcds-run";

  runScript = writeShellScript "srcds-run" ''
    if [ $# -eq 0 ]; then
      echo "Usage: srcds-run command-to-run args..." >&2
      exit 1
    fi

    exec "$@"
  '';

  targetPkgs = allPkgs;
  multiPkgs = allPkgs;
  multiArch = true;
}
