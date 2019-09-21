with import (fetchTarball {
  url = https://github.com/nixos/nixpkgs-channels/archive/00ef72610c82dd0ea69f2bc3f70445483acca0d0.tar.gz;
  sha256 = "0i4kqf5hx7zgd1cf2sj2zaalf7rmd246l664r2wc26w56ya5z1nv";
}) {};
stdenv.mkDerivation {
  name = "polybar-spotify";
  buildInputs = [
    go_1_12
    (gocode.override { buildGoPackage = buildGo112Package; })
    (gocode-gomod.override { buildGoPackage = buildGo112Package; })
    cacert
    pkgconfig
    libxml2
  ];
  shellHook = ''
    unset GOPATH
  '';
}
