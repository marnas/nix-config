{ musicDirectory, vars, ... }: {
  services.mpd = {
    enable = true;
    inherit musicDirectory;

    extraConfig = ''
      audio_output {
        type "${if vars.hostname == "macos" then "osx" else "pipewire"}"
        name "${if vars.hostname == "macos" then "CoreAudio" else "PipeWire Sound Server"}"
        ${if vars.hostname == "macos" then "mixer_type \"software\"" else "# No format specified = bit-perfect passthrough at native sample rates"}
      }

      # Disable resampling to maintain bit-perfect playback
      resampler {
        plugin "internal"
      }

      # Buffer settings for high-resolution audio
      audio_buffer_size "4096"

      auto_update "yes"
      #restore_paused "yes"
    '';
  };
}
