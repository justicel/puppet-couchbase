# == Class: couchbase::repository
# 
# Sets up the couchbase repo depending on OS
# The repo is used to install the client library.
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
class couchbase::repository {
  include ::couchbase::params

  case $::couchbase::params::repository {
    'redhat': { contain ::couchbase::repository::redhat }
    'debian': { contain ::couchbase::repository::debian }
    default: { }
  }
}
