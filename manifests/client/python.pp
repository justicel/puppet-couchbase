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
  $package_ensure = present,
  $client_package = $::couchbase::params::client_package,
  $development_package = $::couchbase::params::development_package
) inherits ::couchbase::params {
  package { 'couchbase_python':
    ensure   => $package_ensure,
    name     => 'couchbase',
    provider => 'pip',
    require  => [
      Package[$client_package],
      Package[$development_package]
    ]
  }
}
