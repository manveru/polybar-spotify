{ pkgs ? import (fetchTarball {
    url = https://github.com/NixOS/nixpkgs-channels/archive/3265226fec3bd568d5828485c03e15e2e87d3d12.tar.gz;
    sha256 = "10rmdj6zbh9da4rhrs77yhvckjlpfqbz5208zdjysvlv28wj9yd5";
  }) {}
}:
with builtins;
let
  inherit (pkgs.lib) hasPrefix splitString;
  projects = (fromJSON ( readFile "${goDeps}/Gopkg.json" )).projects;
  projectSources = map (project:
    pkgs.stdenv.mkDerivation {
      name = replaceStrings ["/"] ["-"] project.name;
      src = fetchGit {
        url = (if ( hasPrefix "golang.org" project.name ) then
          "https://go.googlesource.com/" + ( elemAt (splitString "/" project.name) 2 )
        else
          "https://" + project.name);
        rev = project.revision;
      };
      phases = "buildPhase";
      buildPhase = ''
        mkdir -p $out/package
        cp -r $src/* $out/package
        echo "${project.name}" > $out/name
      '';
    }
  ) projects;

  goDeps = pkgs.stdenv.mkDerivation {
    name = "goDeps";
    src = ./Gopkg.lock;
    phases = "buildPhase";
    buildInputs = [ pkgs.remarshal ];
    buildPhase = ''
      mkdir -p $out
      remarshal --indent-json -if toml -i $src -of json -o $out/Gopkg.json
    '';
  };

  depTree = pkgs.stdenv.mkDerivation {
    name = "depTree";
    src = projectSources;
    phases = "buildPhase";
    buildPhase = ''
      mkdir -p $out
      for pkg in $src; do
        echo building $pkg
        name="$(cat $pkg/name)"
        mkdir -p $out/vendor/$name
        cp -r $pkg/package/* $out/vendor/$name
      done
    '';
  };
in pkgs.stdenv.mkDerivation {
  name = "polybar-spotify";
  src = ./.;
  buildInputs = with pkgs; [
    go_1_10
  ];

  phases = "buildPhase";
  buildPhase = ''
    set -e
    dst=$out/src/github.com/manveru/polybar-spotify
    mkdir -p $dst
    cp -r $src/*.go $dst
    export GOPATH=$out
    ln -s ${depTree}/vendor $dst/vendor
    (
      cd $dst
      go build
      mkdir -p $out/bin
      cp polybar-spotify $out/bin/polybar-spotify
    )
  '';
}
