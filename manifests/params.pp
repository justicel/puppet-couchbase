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
      if versioncmp($::operatingsystemmajrelease, '7') >= 0  {
        $openssl_package     = ['openssl-libs']
        $osname              = 'centos7'
      } else {
        $openssl_package     = ['openssl098e']
        $osname              = 'centos6'
      }
      $installer           = 'rpm'
      $pkgtype             = 'rpm'
      $development_package = 'libcouchbase-devel'
      $repository          = 'redhat'
      $pkgarch             = '.x86_64'
      $pkgverspacer        = '-'
      $dependencies        = []
    }
    'Debian': {
      $openssl_package = ['openssl']
      $installer       = 'dpkg'
      $pkgtype         = 'deb'
      $development_package = 'libcouchbase-dev'
      $repository      = 'debian'
      $pkgarch         = '_amd64'
      $pkgverspacer    = '_'
      $dependencies    = ['python-httplib2']
      case $::operatingsystem {
        'Debian': {
          $osname = 'debian7'
        }
        'Ubuntu': {
          case $::operatingsystemrelease {
            '18.04': {
              $osname = 'ubuntu18.04'
            }
            '16.04': {
              $osname = 'ubuntu16.04'
            }
            '14.04': {
              $osname = 'ubuntu14.04'
            }
            default: {
              $osname = 'ubuntu12.04'
            }
          }
        }
        default: { }
      }
    }
    default: {
      fail("Class['couchbase::params']: Unsupported OS: ${::osfamily}")
    }
  }
}
