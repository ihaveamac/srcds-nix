{ pkgs ? import <nixpkgs> { } }:

{
  modules = import ./modules;
}
