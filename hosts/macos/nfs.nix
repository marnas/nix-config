{ lib, config, pkgs, ... }: {
  # macOS NFS configuration
  # Note: macOS has built-in NFS support, no additional packages needed

  # Ensure mount point exists
  system.activationScripts.nfs.text = ''
    mkdir -p /Volumes/media
  '';

  # Create a launchd daemon for automatic mounting at boot
  launchd.daemons.nfs-mount = {
    script = ''
      # Wait for network to be available
      sleep 10

      # Create mount point if it doesn't exist
      mkdir -p /Volumes/media

      # Mount if not already mounted
      if ! /sbin/mount | /usr/bin/grep -q "/Volumes/media"; then
        /bin/echo "Mounting NFS share truenas.marnas.sh:/mnt/Pool1/media..."
        /sbin/mount -t nfs -o resvport,rw truenas.marnas.sh:/mnt/Pool1/media /Volumes/media
      fi
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/nfs-mount.log";
      StandardErrorPath = "/tmp/nfs-mount.err";
    };
  };
}
