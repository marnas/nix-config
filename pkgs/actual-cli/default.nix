{
  lib,
  buildNpmPackage,
  python3,
}:
buildNpmPackage {
  pname = "actual-cli";
  version = "26.6.0";

  src = ./.;

  npmDepsHash = "sha256-H2CmopB54DBUuijf1eazDJNCA/P44Z1DHdUpuEN3Tpw=";

  # `actual` — verb-based CLI over the official Actual Budget API package
  # (@actual-app/api). Script body lives in ./actual.mjs; see its header comment for
  # the credential flow (Infisical) and API gotchas. The pinned @actual-app/api version
  # (package.json + lockfile) must track the sync-server version at actual.marnas.sh —
  # check `curl https://actual.marnas.sh/info` and bump version/lock/hash together.
  #
  # No build step: actual.mjs ships as-is. better-sqlite3 (native dep of
  # @actual-app/api) can't download its prebuilt binding in the sandbox, so its install
  # script falls back to compiling via node-gyp — which needs python on PATH.
  dontNpmBuild = true;
  nativeBuildInputs = [ python3 ];

  meta = {
    description = "Verb-based CLI over the official Actual Budget API";
    homepage = "https://actualbudget.org/docs/api/";
    platforms = lib.platforms.unix;
    mainProgram = "actual";
  };
}
