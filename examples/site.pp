class { 'couchbase':
  size     => 256,
  user     => 'couchbase',
  password => 'password',
  version  => '4.1.0',
  edition  => 'enterprise',
}

couchbase::bucket { 'default':
  port     => 11211,
  size     => 256,
  user     => 'couchbase',
  password => 'password',
  type     => 'couchbase',
  replica  => 1,
}
