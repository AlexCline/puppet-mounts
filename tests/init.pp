nfs { 'Test NFS mount':
  source => '/dev/sdb2',
  dest   => '/a/path/to/data',
  type   => 'ext4'
}

nfs { 'Another test NFS mount':
  ensure => present,
  source => 'host.example.com',
  dest   => '/a/path/to/more/data',
  type   => 'nfs',
  opts   => 'ro,defaults,noatime,nofail',
}

nfs { 'Remove another test NFS mount':
  ensure => absent,
  source => 'host.example.com',
  dest   => '/a/path/to/more/data',
  type   => 'nfs',
  opts   => 'ro,defaults,noatime,nofail',
}