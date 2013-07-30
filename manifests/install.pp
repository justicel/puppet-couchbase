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
  $version = $couchbase::params::version,
) {
  package {'couchbase-server-enterprise':
    ensure   => installed,
    name     => 'couchbase-server',
    provider => rpm,
    source   => 'http://packages.couchbase.com/releases/2.1.0/couchbase-server-enterprise_x86_64_2.1.0.rpm',
    require  => Package['openssl098e'],
  }
  package {'openssl098e': }
}
