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

      # Ensure the entire tree of the destination has been created.
      $dirtree = dirtree($dest)
      ensure_resource('file', $dirtree, {'ensure' => 'directory'})

      fstab { "fstab entry for ${source} to ${dest} as ${type}":
        source => $source,
        dest   => $dest,
        type   => $type,
        opts   => $opts,
        ensure => $ensure,
      }

      exec { "/bin/mount '${dest}'":
        unless  => "/bin/mount -l | /bin/grep '${dest}'",
        require => [File[$dirtree], Fstab["fstab entry for ${source} to ${dest} as ${type}"]],
      }

    }
    default: { error('Your OS isn\'t supported by the fstab module yet.') }
  }

}
