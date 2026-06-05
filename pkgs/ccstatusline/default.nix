{
  stdenvNoCC,
  fetchurl,
  nodejs,
  makeWrapper,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ccstatusline";
  version = "2.2.19";

  src = fetchurl {
    url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${finalAttrs.version}.tgz";
    hash = "sha256-ZECyfJStzolhs1EQrrbq6svXCtvcpj6YJRPjFIazLSw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ccstatusline
    cp -r . $out/lib/ccstatusline/
    makeWrapper ${lib.getExe nodejs} $out/bin/ccstatusline \
      --add-flags $out/lib/ccstatusline/dist/ccstatusline.js
    runHook postInstall
  '';

  meta = {
    description = "Highly customizable statusline for Claude Code CLI";
    homepage = "https://github.com/sirmalloc/ccstatusline";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "ccstatusline";
  };
})
