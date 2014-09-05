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
  $version = $couchbase::version,
  $edition = $couchbase::edition,
  $method  = $couchbase::install_method,
) {
  include couchbase::params

  $pkgname = $edition ? {
        'enterprise'  => "couchbase-server-enterprise_${version}_x86_64.${couchbase::params::pkgtype}",
        'community'   => "couchbase-server-community_${version}_x86_64.${couchbase::params::pkgtype}",
        default       => "couchbase-server-enterprise_${version}_x86_64.${couchbase::params::pkgtype}",
    }

  $pkgsource = "http://packages.couchbase.com/releases/${version}/${pkgname}"

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
        notify   => Exec['couchbase-init'],
        provider => $couchbase::params::installer,
        require  => [Package[$couchbase::params::openssl_package], Exec['download_couchbase']],
        source   => "/opt/${pkgname}",
      }
    }
    'package': {
      package {'couchbase-server':
        ensure   => $couchbase::version,
        name     => 'couchbase-server',
        notify   => Exec['couchbase-init'],
        require  => Package[$couchbase::params::openssl_package],
      }
    }
    default: {
      fail ("$module_name install_method must be 'package' or 'curl'")
    }
  }

  if !defined(Package[$couchbase::params::openssl_package]) {
    ensure_packages($couchbase::params::openssl_package)
  }

}
