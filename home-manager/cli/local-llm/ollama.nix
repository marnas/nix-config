{ lib, pkgs, ... }:
{
  # Host-local Ollama backing the local-LLM agents.
  services.ollama = {
    enable = true;
    # Linux uses ROCm with a gfx version spoof for Navi 22 (gfx1031 -> gfx1030).
    # macOS uses Metal via the default ollama package and ignores these.
    acceleration = lib.mkIf pkgs.stdenv.isLinux "rocm";
    environmentVariables = lib.mkIf pkgs.stdenv.isLinux {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };
}
