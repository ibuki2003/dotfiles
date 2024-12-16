# nil (Nix LSP), from GitHub
{
  pkgs,
  sources,
}:

pkgs.rustPlatform.buildRustPackage rec {

  inherit (pkgs.nil) pname preBuild;
  passthru.updateScript = pkgs.nil.updateScript;

  inherit (sources.nil) src version;
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ (pkgs.lib.getBin pkgs.nixVersions.latest) ];
  env.CFG_RELEASE = version;

  # meta = pkgs.lib.attrsets.getAttrs [
  #   "description" "homepage" "changelog" "license" "maintainers" "mainProgram"
  # ] pkgs.nil.meta;
  meta = pkgs.nil.meta;
}
