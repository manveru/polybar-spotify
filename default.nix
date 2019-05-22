{ buildGoModule }:
let
  srcWithout = rootPath: ignoredPaths:
    let ignoreStrings = map (path: toString path ) ignoredPaths;
    in builtins.filterSource (path: type: (builtins.all (i: i != path) ignoreStrings)) rootPath;
in buildGoModule {
  pname = "polybar-spotify";
  version = "0.2.0";
  src = srcWithout ./. [ ./result ./.git ./default.nix ];
  modSha256 = "0cmiy6zbwrdnhni60mgv8xlb0fbr4glpbwir2zdjz9hyma45vz35";
}
