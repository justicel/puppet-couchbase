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
) {
  include couchbase::params

  $pkgname = $edition ? {
        'enterprise'  => "couchbase-server-enterprise_${version}_x86_64.${couchbase::params::pkgtype}",
        'community'   => "couchbase-server-community_x86_64_${version}.${couchbase::params::pkgtype}",
        default       => "couchbase-server-enterprise_${version}_x86_64.${couchbase::params::pkgtype}",
    }

  notify {"Downloading ${pkgname} package":}


  $pkgsource = "http://packages.couchbase.com/releases/${version}/${pkgname}"

  exec { 'download_couchbase':
    command => "curl -o /tmp/${pkgname} ${pkgsource}",
    creates => "/tmp/${pkgname}",
    path    => ['/usr/bin','/usr/sbin','/bin','/sbin'],
  }

  package {'couchbase-server':
    ensure   => installed,
    name     => 'couchbase-server',
    provider => $couchbase::params::installer,
    source   => "/tmp/${pkgname}",
    require  => Package[$couchbase::params::openssl_package],
  }

  if ! defined(Package[$couchbase::params::openssl_package]) {
    package {$couchbase::params::openssl_package: }
  }
}
