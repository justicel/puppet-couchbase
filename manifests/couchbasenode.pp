# == Class: couchbase::couchbasenode
#
# Defines a node in the couchbase cluster (using storeconfigs).
#
# === Parameters
# [*server_name*]
# The defined name to give this server (could be IP or fqdn)
# [*server_group*]
# The grouping for storeconfigs under which this particular server lives
# [*user*]
# Login user for couchbase
# [*password*]
# Password to login to couchbase servers
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

define couchbase::couchbasenode (
  $server_name  = $::fqdn,
  $server_group = 'default',
  $user         = 'couchbase',
  $password     = 'password',
  $ensure       = $::couchbase::params::ensure,
  $autofailover = $::couchbase::params::autofailover,
) {
  include ::couchbase::params

  if $ensure == present {
    concat::fragment { "${server_group}_couchbase_server_${name}":
      order   => "20-${server_group}-${server_name}",
      target  => $::couchbase::params::cluster_script,
      content => template('couchbase/couchbasenode.erb'),
      notify  => Exec['couchbase-cluster-setup'],
    }
  }
  elsif $ensure == absent {
    concat::fragment { "${server_group}_couchbase_server_${name}":
      order   => "20-${server_group}-${server_name}",
      target  => $::couchbase::params::cluster_script,
      content => template('couchbase/couchbasenode_remove.erb'),
      notify  => Exec['couchbase-cluster-setup'],
    }
  }
}
