# == Class: couchbase::repository::redhat
#
# Sets up the couchbase repo for redhat distros
#
# === Authors
#
# Alex Farcas <alex.farcas@gmail.com>
#
class couchbase::repository::redhat {
  include couchbase::params

  $couchbase_os_version = $::operatingsystemrelease ? {
    /^5\./  => '5.5',
    /^6\./  => '6.2',
    default => '0.0',
  }

  $baseurl = 'http://packages.couchbase.com/rpm'

  yumrepo { 'couchbase':
    enabled  => '1',
    gpgcheck => '1',
    baseurl  => "${baseurl}/${couchbase_os_version}/${::architecture}",
    gpgkey   => "${baseurl}/couchbase-rpm.key",
    descr    => 'Couchbase package repository',
    priority => 1,
  }
}
