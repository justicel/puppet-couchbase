# == Class: couchbase::client::python
#
# Installs the python client library. 
# Not meant to be used directly, instead see class couchbase::client
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
class couchbase::client::python(
  $package_ensure = present
) {
  include couchbase::params

  package { 'couchbase_python':
    ensure   => $package_ensure,
    name     => 'couchbase',
    provider => 'pip',
    require  => [
      Package[$::couchbase::params::client_package], 
      Package[$::couchbase::params::development_package]
    ]
  }
}
