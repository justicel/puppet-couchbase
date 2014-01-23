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

  $cluster_script = '/usr/local/bin/couchbase-cluster-setup.sh'
  $version        = '2.2.0'

  case $osfamily {
    Redhat: {
      $openssl_package = 'openssl098e'
      $installer       = 'rpm'
      $pkgtype         = 'rpm'
    }
    Debian: {
      $openssl_package = 'openssl'
      $installer       = 'dpkg'
      $pkgtype         = 'deb'
    }
  }
}
