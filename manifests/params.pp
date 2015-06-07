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

  $node_init_script    = '/usr/local/bin/couchbase-node-init.sh'
  $cluster_init_script = '/usr/local/bin/couchbase-cluster-init.sh'
  $cluster_script      = '/usr/local/bin/couchbase-cluster-setup.sh'
  $node_init_lock      = '/opt/couchbase/var/.node_init'
  $version             = '3.0.1'
  $edition             = 'community'
  $client_package      = 'libcouchbase2-libevent'
  $download_url_base   = 'http://packages.couchbase.com/releases'
  $ensure              = 'present'
  $autofailover        = true
  $data_dir            = '/opt/couchbase/var/lib/couchbase/data'
  $moxi_port           = '11311'
  $moxi_version        = '2.5.0'

  case $::osfamily {
    /(?i:centos|redhat|scientific)/: {
      $openssl_package     = ['openssl098e']
      $installer           = 'rpm'
      $pkgtype             = 'rpm'
      $development_package = 'libcouchbase-devel'
      $repository          = 'redhat'
      $osname              = 'centos6'
      $pkgarch             = '.x86_64'
      $pkgverspacer        = '-'
    }
    'Debian': {
      $openssl_package = ['openssl']
      $installer       = 'dpkg'
      $pkgtype         = 'deb'
      $development_package = 'libcouchbase-dev'
      $repository      = 'debian'
      $pkgarch         = '_amd64'
      $pkgverspacer    = '_'
      case $::operatingsystem {
        'Debian': {
          $osname = 'debian7'
        }
        'Ubuntu': {
          $osname = 'ubuntu12.04'
        }
        default: { }
      }
    }
    default: {
      fail("Class['couchbase::params']: Unsupported OS: ${::osfamily}")
    }
  }
}
