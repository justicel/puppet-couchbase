# == Type: couchbase::client
#
# Installs the libcouchbase client library, and the SDK for the desired programming language.
# If the language is not specified, it will only install libcouchbase.
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
define couchbase::client(
  $package_ensure = present,
  $client_package = $::couchbase::params::client_package,
  $development_package = $::couchbase::params::development_package
) {
  include ::couchbase::repository
  
  if ! defined(Package[$development_package]) {
    package { $development_package:
      ensure  => $package_ensure,
      require => Class['couchbase::repository'],
    }
  }
  
  if ! defined(Package[$client_package]) {
    package { $client_package:
      ensure  => $package_ensure,
      require => Package[$development_package],
    }
  }
  
  case $title {
    ruby: { 
      class { '::couchbase::client::ruby':
        package_ensure      => $package_ensure,
        client_package      => $client_package,
        development_package => $development_package,
      }      
    }
    python: { 
      class { '::couchbase::client::python':
        package_ensure      => $package_ensure,
        client_package      => $client_package,
        development_package => $development_package,
      }      
    }
    default: { }
  }
}
