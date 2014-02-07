# == Class: couchbase::bucket
#
# Couchbase bucket script. This allows you to create new buckets for couchbase
# installation. Through this you can define the size of the bucket, type,
# replica count, etc.
#
# === Parameters
# [*port*]
# The port to use for the couchbase bucket
# [*size*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*user*]
# Login user for couchbase
# [*password*]
# Password to login to couchbase servers
# [*type*]
# The type of the bucket to create (memcached/couchbase)
# [*replica*]
# Count of replicas for bucket
#
# === Examples
#
# couchbase::bucket { 'bucketname':
#   port     => 11211,
#   size     => 1024,
#   user     => 'couchbase',
#   password => 'password',
#   type     => 'memcached',
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
define couchbase::bucket (
  $port     = 8091,
  $size     = 1024,
  $user     = 'couchbase',
  $password = 'password',
  $type     = 'memcached',
  $replica  = 1,
  $flush    = 0,
) {

  # all this has to be done before we can create buckets.
  Class['couchbase::install'] -> Couchbase::Bucket[$title]
  Class['couchbase::config'] -> Couchbase::Bucket[$title]
  Class['couchbase::service'] -> Couchbase::Bucket[$title]



  exec {"bucket-create-${title}":
    path      => ['/opt/couchbase/bin/', '/usr/bin/', '/bin', '/sbin', '/usr/sbin'],
    command   => "couchbase-cli bucket-create -c localhost -u ${user} -p '${password}' --bucket=${title} --bucket-type=${type} --bucket-ramsize=${size} --bucket-port=${port} --bucket-replica=${replica} --enable-flush=${flush}",
	unless    => "couchbase-cli bucket-list -c localhost -u ${user} -p '${password}' | grep ${title}",
    require   => Class['couchbase::config'],
    returns   => [0, 2],
    logoutput => true
  }

}
