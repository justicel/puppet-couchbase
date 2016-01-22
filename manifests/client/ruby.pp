# == Class: couchbase::client::ruby
#
# Installs the ruby client library. 
# Not meant to be used directly, instead see class couchbase::client
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
class couchbase::client::ruby(
  $package_ensure = present,
  $client_package = $::couchbase::params::client_package,
  $development_package = $::couchbase::params::development_package
) inherits ::couchbase::params {
  package { 'couchbase_ruby':
    ensure   => $package_ensure,
    name     => 'couchbase',
    provider => 'gem',
    require  => [
      Package[$client_package],
      Package[$development_package]
    ]
  }
}
