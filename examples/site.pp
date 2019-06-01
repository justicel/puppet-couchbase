class { '::couchbase':
  size     => 256,
  user     => 'couchbase',
  password => 'password',
  version  => '6.0.1',
  edition  => 'enterprise',
}

couchbase::bucket { 'default':
  size     => 256,
  user     => 'couchbase',
  password => 'password',
  type     => 'couchbase',
  replica  => 1,
}
