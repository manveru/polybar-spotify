{ buildGoModule }:
let
  srcWithout = rootPath: ignoredPaths:
    let ignoreStrings = map (path: toString path ) ignoredPaths;
    in builtins.filterSource (path: type: (builtins.all (i: i != path) ignoreStrings)) rootPath;
in buildGoModule {
  pname = "polybar-spotify";
  version = "0.2.0";
  src = srcWithout ./. [ ./result ./.git ./default.nix ];
  modSha256 = "060qclqn219i4lfm8w9dn1f4fzsn90m63m5yg001vpcya7csqijn";
}
