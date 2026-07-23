{ pkgs, ... }:
{
  # FPV tooling. ExpressLRS Configurator flashes/configures ELRS transmitter
  # modules and receivers (e.g. RadioMaster Boxer internal TX, BetaFPV onboard
  # RX). It's a Linux-only GUI, so this module is imported by the NixOS host only.
  #
  # Companion system-level config — serial/DFU udev access for radios and flight
  # controllers — lives in hosts/nixos/udev-rules.nix. udev is managed by NixOS,
  # not standalone home-manager, so it can't be consolidated here.

  home.packages = [ pkgs.expresslrs-configurator ];

  nixpkgs = {
    overlays = [
      # The binary-flashing strategy spawns a bundled flasher.pyz
      # (#!/usr/bin/env python3), but the upstream wrapper only puts git on PATH,
      # so the spawn fails with an empty "generic error". Add python3 to PATH.
      (final: prev: {
        expresslrs-configurator = prev.expresslrs-configurator.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
          postInstall = (old.postInstall or "") + ''
            wrapProgram $out/bin/expresslrs-configurator \
              --prefix PATH : ${final.lib.makeBinPath [ final.python3 ]}
          '';
        });
      })
    ];
  };
}
