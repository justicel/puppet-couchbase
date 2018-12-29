# == Class: couchbase
#
# Initial entry-point for the couchbase puppet script. Uses storeconfigs
# and puppetdb to save each node into a cluster based upon a defined
# server group.
#
# === Parameters
# [*ensure*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*size*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*user*]
# Login user for couchbase
# [*password*]
# Password to login to couchbase servers
# [*version*]
# The package version of the couchbase module to use
# [*edition*]
# The package edition of the couchbase module to use (e.g. community)
# [*nodename*]
# How this particular node will be defined in the cluster. By default it is
# set to the fqdn of the server the module is being launched on
# [*server_group*]
# The group in which this couchbase server will live. Set to 'default'
# [*install_method*]
#  The method used to install the couchbase server. Can be either curl
#  or package
# [*autofailover*]
#  Should the cluster autofailover
# [*data_dir*]
#  The directory used to store the data. Must be an absolute path.
# [*index_dir*]
#  The directory used to store the index of the data. Must be an absolute path.
# [*download_url_base*]
#  The url used to fetch the repository without version nor edition
#
# === Examples
#
# class { 'couchbase':
#   size         => 1024,
#   user         => 'couchbase',
#   password     => 'password',
#   version      => latest,
#   nodename     => $::ipaddress,
#   server_group => 'default',
# }
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

class couchbase
(
  $ensure            = 'present',
  $size              = 512,
  $user              = 'couchbase',
  $password          = 'password',
  $version           = $::couchbase::params::version,
  $edition           = $::couchbase::params::edition,
  $nodename          = $::fqdn,
  $server_group      = 'default',
  $install_method    = 'curl',
  $autofailover      = $::couchbase::params::autofailover,
  $data_dir          = $::couchbase::params::data_dir,
  $index_dir         = undef,
  $services          = 'data',
  $download_url_base = $::couchbase::params::download_url_base,
) inherits ::couchbase::params {

  validate_numeric($size)
  validate_string($user)
  validate_string($password)
  validate_string($version)
  validate_string($edition)
  validate_string($nodename)
  validate_string($server_group)
  validate_re($install_method, ['curl', 'package'])
  validate_string($ensure)
  validate_bool($autofailover)
  validate_absolute_path($data_dir)
  if ($index_dir) {
    validate_absolute_path($index_dir)
  }
  validate_string($download_url_base)

  # Define initialized node as a couchbase node (This will always be true
  # so this is a safe assumption to make.
  @@couchbase::couchbasenode { $nodename:
    ensure       => $ensure,
    server_name  => $nodename,
    server_group => $server_group,
    user         => $user,
    password     => $password,
  }

  if $ensure == present {
    anchor {
      'couchbase::begin':;
      'couchbase::end':;
    }

    Anchor['couchbase::begin'] ->

    class {'::couchbase::install':
      version  => $version,
      edition  => $edition,
      data_dir => $data_dir,
    }

    ->

    class {'::couchbase::service':}

    ->

    class {'::couchbase::config':
      size         => $size,
      services     => $services,
      user         => $user,
      password     => $password,
      server_group => $server_group,
      autofailover => $autofailover,
    }

    ->

    Anchor['couchbase::end']

  }
  elsif $ensure == absent {

    # Removing node init lock.
    file {$::couchbase::params::node_init_lock:
      ensure => absent,
    }

    anchor {
      'couchbase::begin':;
      'couchbase::end':;
    }

    Anchor['couchbase::begin'] ->

    class {'::couchbase::install':
      version           => $version,
      edition           => $edition,
      download_url_base => $download_url_base,
    }

    ->

    class {'::couchbase::config':
      ensure       => $ensure,
      size         => $size,
      user         => $user,
      password     => $password,
      server_group => $server_group,
    }

    ->

    Anchor['couchbase::end']
  }

}
