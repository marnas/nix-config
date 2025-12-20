{ lib, config, pkgs, ... }: {
  # macOS NFS configuration using automount (autofs)
  # This mounts on-demand when you access /nfs/media, saving battery life
  # Note: macOS has built-in NFS and autofs support, no additional packages needed

  # Ensure mount point exists
  system.activationScripts.nfs.text = ''
    mkdir -p /nfs/media
  '';

  # Configure autofs for on-demand NFS mounting
  # Create /etc/auto_nfs with the mount configuration
  environment.etc."auto_nfs".text = ''
    # Auto-mount NFS share on demand
    # Format: local_name  [mount_options]  nfs_server:/remote/path
    media  -fstype=nfs,resvport,rw  truenas.marnas.sh:/mnt/Pool1/media
  '';

  # Add entry to auto_master to enable /nfs automount
  environment.etc."auto_master".text = ''
    #
    # Automounter master map
    #
    +auto_master		# Use directory service
    #/net			-hosts		-nobrowse,hidefromfinder,nosuid
    /home			auto_home	-nobrowse,hidefromfinder
    /Network/Servers	-fstab
    /-			-static
    /nfs			auto_nfs	-nobrowse
  '';
}
