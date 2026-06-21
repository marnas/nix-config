{ lib, pkgs, ... }:
{
  # Host-local Ollama backing the local-LLM agents.
  services.ollama = {
    enable = true;
    # Linux uses ROCm with a gfx version spoof for Navi 22 (gfx1031 -> gfx1030).
    # macOS uses Metal via the default ollama package and ignores these.
    acceleration = lib.mkIf pkgs.stdenv.isLinux "rocm";
    environmentVariables = {
      # Default would auto-pick ~8k on this VRAM; raise it so codebase-sized
      # prompts (agentic reviews) fit. Server-wide; larger = more KV cache.
      OLLAMA_CONTEXT_LENGTH = "32768";
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };
}
