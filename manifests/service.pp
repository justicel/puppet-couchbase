# == Class: couchbase::bucket
#
# Service definition for couchbase server.
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
class couchbase::service {
  service {'couchbase-server':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }
}
