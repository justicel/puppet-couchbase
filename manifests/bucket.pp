# == Class: couchbase::bucket
#
# Couchbase bucket script. This allows you to create new buckets for couchbase
# installation. Through this you can define the size of the bucket, type,
# replica count, etc.
#
# === Parameters
# [*size*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*user*]
# Login user for the couchbase cluster
# [*password*]
# Password for the couchbase cluster
# [*type*]
# The type of the bucket to create (memcached/couchbase)
# [*replica*]
# Count of replicas for bucket
# [*bucket_password*]
# The password to use for the new bucket. Note that per the couchbase docs
# only buckets on port 11211 can use SASL authentication.

# === Examples
#
# couchbase::bucket { 'bucketname':
#   size            => 1024,
#   user            => 'couchbase',
#   password        => 'password',
#   type            => 'memcached',
#   bucket_password => 'somepw'
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
  $bucketname      = $title,
  $size            = 1024,
  $user            = 'couchbase',
  $password        = 'password',
  $type            = 'memcached',
  $replica         = 1,
  $bucket_password = undef,
  $flush           = 0,
) {

  include ::couchbase::params

  if $::couchbase::ensure == present {
    # all this has to be done before we can create buckets.
    Class['couchbase::install'] -> Couchbase::Bucket[$title]
    Class['couchbase::config'] -> Couchbase::Bucket[$title]
    Class['couchbase::service'] -> Couchbase::Bucket[$title]

    # SECURITY (GH #42): the cluster/bucket passwords are exported through the
    # command's environment (CB_PASSWORD / CB_BUCKET_PASSWORD) and referenced as
    # shell variables so the secret never appears in the command string itself.
    # Puppet always logs the literal command attribute when an Exec fails
    # ("change from notrun ... failed: <command> returned 1"), and tagmail will
    # e-mail that report, so an inlined password would be leaked in plaintext
    # regardless of the logoutput setting.
    $create_defaults = "-u ${user} -p \"\$CB_PASSWORD\" --bucket=${bucketname} --bucket-type=${type} --bucket-ramsize=${size} --enable-flush=${flush}"
    if $bucket_password {
      $create_pwd = "${create_defaults} --bucket-password=\"\$CB_BUCKET_PASSWORD\""
    }
    else {
      $create_pwd = $create_defaults
    }

    $create_command = $type ? {
      'memcached' => $create_defaults,
      default     => "${create_pwd} --bucket-replica=${replica}"
    }

    # Only export the bucket password when one is actually configured.
    $exec_environment = $bucket_password ? {
      undef   => ["CB_PASSWORD=${password}"],
      default => ["CB_PASSWORD=${password}", "CB_BUCKET_PASSWORD=${bucket_password}"],
    }

    exec {"bucket-create-${bucketname}":
      path        => ['/opt/couchbase/bin/', '/usr/bin/', '/bin', '/sbin', '/usr/sbin'],
      command     => "couchbase-cli bucket-create -c 127.0.0.1 ${create_command}",
      unless      => "couchbase-cli bucket-list -c 127.0.0.1 -u ${user} -p \"\$CB_PASSWORD\" | grep -x ${bucketname}",
      environment => $exec_environment,
      provider    => shell,
      require     => Class['couchbase::config'],
      returns     => [0, 2],
      logoutput   => on_failure,
    }
  }
  else {
    notify {'Couchbase is configured to be absent. Bucket can not be configured.':}
  }


}
