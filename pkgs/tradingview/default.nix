# TradingView Desktop — proprietary Electron app, repackaged from the official
# Debian build. Upstream ships no AppImage; the .deb is the only direct download.
#
# The "latest" URL is unversioned, so the hash is pinned to a known build. When
# upstream publishes a new version the fetch fails with a hash mismatch: bump
# `version` and refresh `hash` (nix-prefetch-url the .deb, then `nix hash`).
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libxkbcommon,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tradingview";
  version = "3.2.0";

  src = fetchurl {
    url = "https://tvd-packages.tradingview.com/ubuntu/stable/latest/jammy/tradingview_amd64.deb";
    hash = "sha256-Jm6xqFGOQtyWez271G8gagX9uK2Bqe1n5ESciq+8/KY=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libsecret
    libxkbcommon
    nspr
    nss
    pango
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
  ];

  # dlopen-ed at runtime; add to every elf's runpath so they resolve.
  runtimeDependencies = [
    (lib.getLib systemd) # libudev
    libnotify
    libpulseaudio
  ];

  unpackCmd = "dpkg-deb -x $curSrc source";
  sourceRoot = "source";

  # Let makeWrapper own the final wrapper so the GTK/Wayland args land together.
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r opt/TradingView $out/opt/TradingView

    install -Dm644 usr/share/applications/tradingview.desktop \
      $out/share/applications/tradingview.desktop
    install -Dm644 usr/share/icons/hicolor/512x512/apps/tradingview.png \
      $out/share/icons/hicolor/512x512/apps/tradingview.png
    substituteInPlace $out/share/applications/tradingview.desktop \
      --replace-fail /opt/TradingView/tradingview $out/bin/tradingview

    # Run under XWayland. Native Wayland + GPU acceleration deadlocks the GPU
    # process on a surface reconfigure when leaving fullscreen on Hyprland and
    # never recovers. Use the hard --ozone-platform=x11 (not the softer
    # --ozone-platform-hint, which Electron overrides back to wayland whenever
    # XDG_SESSION_TYPE=wayland). XWayland keeps GPU acceleration (smooth charts)
    # and survives fullscreen toggles; trade-off is slightly softer text on
    # fractional scaling. For native Wayland instead, use --ozone-platform=wayland
    # plus --disable-gpu (software rendering) to dodge the freeze.
    makeWrapper $out/opt/TradingView/tradingview $out/bin/tradingview \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--no-sandbox"

    runHook postInstall
  '';

  meta = {
    description = "TradingView Desktop — charts, screeners and trading (proprietary Electron app)";
    homepage = "https://www.tradingview.com/desktop/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tradingview";
  };
})
