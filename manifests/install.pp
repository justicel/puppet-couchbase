# == Class: couchbase::install
#
# Installs the couchbase-server package on server
#
# === Parameters
# [*version*]
# The version of the couchbase package to install
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
# Portions of code by Lars van de Kerkhof <contact@permanentmarkers.nl>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class couchbase::install (
  $version           = $couchbase::version,
  $edition           = $couchbase::edition,
  $method            = $couchbase::install_method,
  $download_url_base = $couchbase::download_url_base,
  $data_dir = $couchbase::data_dir
) {
  include ::couchbase::params

  $pkgname_enterprise = "couchbase-server-enterprise${::couchbase::params::pkgverspacer}${version}-${::couchbase::params::osname}${::couchbase::params::pkgarch}.${::couchbase::params::pkgtype}"
  $pkgname_community = "couchbase-server-community${::couchbase::params::pkgverspacer}${version}-${::couchbase::params::osname}${::couchbase::params::pkgarch}.${::couchbase::params::pkgtype}"

  $pkgname = $edition ? {
        'enterprise' => $pkgname_enterprise,
        'community'  => $pkgname_community,
        default      => $pkgname_community,
    }

  $pkgsource = "${download_url_base}/${version}/${pkgname}"

  case $method {
    'curl': {
      exec { 'download_couchbase':
        command => "curl -o /opt/${pkgname} ${pkgsource}",
        creates => "/opt/${pkgname}",
        path    => ['/usr/bin','/usr/sbin','/bin','/sbin'],
      }
      package {'couchbase-server':
        ensure   => installed,
        name     => 'couchbase-server',
        provider => $::couchbase::params::installer,
        require  => [Package[$::couchbase::params::openssl_package], Exec['download_couchbase']],
        source   => "/opt/${pkgname}",
      }
    }
    'package': {
      package {'couchbase-server':
        ensure  => $::couchbase::version,
        name    => 'couchbase-server',
        require => Package[$::couchbase::params::openssl_package],
      }
    }
    default: {
      fail ("${module_name} install_method must be 'package' or 'curl'")
    }
  }

  # This is so dumb.
  # https://forums.couchbase.com/t/centos-7-couchbase-server-cannot-start-the-service/6261
  if $::osfamily == 'RedHat' {
    if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
      exec { 'no_symbolic_link':
          path    => '/usr/bin:/usr/local/bin',
          command => 'unlink /etc/init.d/couchbase-server && cp /opt/couchbase/etc/couchbase_init.d /etc/init.d/couchbase-server && systemctl daemon-reload',
          onlyif  => 'test -L /etc/init.d/couchbase-server',
          require => Package['couchbase-server'],
      }
    }
  }

  if ! defined(Package["${::couchbase::params::openssl_package}"]) {
    ensure_packages($::couchbase::params::openssl_package)
  }


  # Ensure data directory is configured properly
  file {$data_dir:
    ensure  => directory,
    recurse => true,
    owner   => 'couchbase',
    require => Package['couchbase-server'],
  }

}
