{
  fetchurl,
  stdenvNoCC,
}:

let
  addonId = "poppup@ibuki2003";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "poppup";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/ibuki2003/poppup/releases/download/v${finalAttrs.version}/poppup-${finalAttrs.version}-unsigned.xpi";
    hash = "sha256-U8FA7P7VWYzU4yWshdxIDZQ8asRwj0/ikxJwS4jrh5A=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" "$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addonId}.xpi"

    runHook postInstall
  '';

  passthru = { inherit addonId; };

  meta = {
    description = "Open URLs received through a custom protocol in popup windows";
    homepage = "https://github.com/ibuki2003/poppup";
    mozPermissions = [ "storage" ];
  };
})
