# == Class: couchbase
#
# Initial entry-point for the couchbase puppet script. Uses storeconfigs
# and puppetdb to save each node into a cluster based upon a defined
# server group.
#
# === Parameters
# [*size*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*user*]
# Login user for couchbase
# [*password*]
# Password to login to couchbase servers
# [*version*]
# The package version of the couchbase module to use
# [*nodename*]
# How this particular node will be defined in the cluster. By default it is
# set to the fqdn of the server the module is being launched on
# [*server_group*]
# The group in which this couchbase server will live. Set to 'default'
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
  $size         = 1024,
  $user         = 'couchbase',
  $password     = 'password',
  $version      = latest,
  $nodename     = $::fqdn,
  $server_group = 'default',
) {

  #Define initialized node as a couchbase node (This will always be true
  #so this is a safe assumption to make.
  @@couchbase::couchbasenode { "${nodename}":
    server_name  => $nodename,
    server_group => $server_group,
    user         => $user,
    password     => $password,
  }

  class {'couchbase::install':
    version => $version
  } ->

  class {'couchbase::config':
    size         => $size,
    user         => $user,
    password     => $password,
    server_group => $server_group,
  } ->

  class {'couchbase::service':}
}
