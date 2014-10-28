# == Class: couchbase::params
#
# Container for module specific parameters
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
class couchbase::params {

  $cluster_script      = '/usr/local/bin/couchbase-cluster-setup.sh'
  $version             = '2.2.0'
  $edition             = 'enterprise'
  $client_package      = 'libcouchbase2-libevent'

  case $osfamily {
    /(?i:centos|redhat|scientific)/: {
      $openssl_package     = ['openssl098e']
      $installer           = 'rpm'
      $pkgtype             = 'rpm'
  	  $development_package = 'libcouchbase-devel'
  	  $repository          = 'redhat'
      $osname              = 'centos6'
    }
    default: {
      $openssl_package     = ['openssl']
      $installer           = 'dpkg'
      $pkgtype             = 'deb'
	  $development_package = 'libcouchbase-dev'
	  $repository          = 'debian'
    }
  }
}
