nfs { 'Test NFS mount':
  source => '/dev/sdb2',
  dest   => '/a/path/to/data',
  type   => 'ext4'
}

nfs { 'Another test NFS mount':
  source => 'host.example.com',
  dest   => '/a/path/to/more/data',
  type   => 'nfs',
  opts   => 'ro,defaults,noatime,nofail',
}