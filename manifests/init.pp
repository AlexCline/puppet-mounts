# Define mounts

define mounts (
  $source = undef,
  $dest   = undef,
  $type   = undef,
  $opts   = 'defaults',
  $dump   = 0,
  $passno = 0,
  $ensure = 'present'){

  if $source == undef {
    error('The source parameter is required.')
  }

  if $dest == undef {
    error('The dest parameter is required.')
  }

  if $type == undef {
    error('The type parameter is required.')
  }

  case $::operatingsystem {
    redhat, centos, amazon: {

      fstab { "fstab entry for ${source} to ${dest} as ${type}":
        ensure => $ensure,
        source => $source,
        dest   => $dest,
        type   => $type,
        opts   => $opts,
      }

      if $type == 'nfs' {
        ensure_resource('package', 'nfs-utils', {'ensure' => 'present'})
        if $::operatingsystemmajrelease == '6' {
          ensure_resource('package', 'rpcbind', {'ensure' => 'present'})
          ensure_resource('service', 'rpcbind', {'ensure' => 'present', 'require' => 'Package["rpcbind"]'})
        }
      }

      case $ensure {
        'present': {
          # Ensure the entire tree of the destination has been created.
          $dirtree = dirtree($dest)
          ensure_resource('file', $dirtree, {'ensure' => 'directory'})

          exec { "/bin/mount '${dest}'":
            unless  => "/bin/mount -l | /bin/grep '${dest}'",
            require => [File[$dirtree], Fstab["fstab entry for ${source} to ${dest} as ${type}"]],
          }
        }
        'absent': {
          exec { "/bin/umount '${dest}'":
            onlyif => "/bin/mount -l | /bin/grep '${dest}'",
            before => Fstab["fstab entry for ${source} to ${dest} as ${type}"],
          }

          # Note: we won't remove the directory since we don't know if it'll destroy data
          notice { "${dest} wasn't removed after being unmounted.  Please remove it manually.": }
        }
        default: { }
      }
    }
    default: { error('Your OS isn\'t supported by the mounts module yet.') }
  }

}
