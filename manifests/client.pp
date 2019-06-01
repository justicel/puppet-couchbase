# == Class: couchbase::client
#
# Installs the libcouchbase client library, and the SDK for the desired programming language.
# If the language is not specified, it will only install libcouchbase.
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
define couchbase::client(
  $package_ensure = present
) {
  include ::couchbase::params
  contain ::couchbase::repository

  Class['::couchbase::repository'] -> Package[$::couchbase::params::development_package]

  package { $::couchbase::params::development_package:
    ensure  => $package_ensure,
  }

  package { $::couchbase::params::client_package:
    ensure  => $package_ensure,
    require => Package[$::couchbase::params::development_package],
  }

  case $title {
    'ruby': { include ::couchbase::client::ruby }
    'python': { include ::couchbase::client::python }
    default: { }
  }
}
