{ musicDirectory, ... }: {
  services.mpd = {
    enable = true;
    inherit musicDirectory;

    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
        # No format specified = bit-perfect passthrough at native sample rates
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
