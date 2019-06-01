# == Class: couchbase::repository::debian
#
# Sets up the couchbase repo for debian distros
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
class couchbase::repository::debian {
  include ::couchbase::params

  apt::source { 'couchbase':
    location => downcase('http://packages.couchbase.com/ubuntu'),
    repos    => "${::lsbdistcodename}/main",
    key      => {
      id     => 'CD406E62',
      source => 'http://packages.couchbase.com/ubuntu/couchbase.key',
    },
    include  => {
      src => false,
    },
  }
}
