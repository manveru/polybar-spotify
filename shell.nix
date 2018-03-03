with import (fetchTarball {
  url = https://github.com/NixOS/nixpkgs-channels/archive/3265226fec3bd568d5828485c03e15e2e87d3d12.tar.gz;
  sha256 = "10rmdj6zbh9da4rhrs77yhvckjlpfqbz5208zdjysvlv28wj9yd5";
}) {};
stdenv.mkDerivation {
  name = "polybar-spotify";
  buildInputs = [ go_1_10 dep ];
  shellHook = ''
    export GOPATH="$HOME/go"
  '';
}
