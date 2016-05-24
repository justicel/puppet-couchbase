# == Class: couchbase::config
#
# Configures the actual couchbase installation. Not meant to be
# launched directly.
#
# === Parameters
# [*size*]
# Initial size (in megabytes) of memory to use for the defined bucket
# [*user*]
# Login user for couchbase
# [*password*]
# Password to login to couchbase servers
# [*server_group*]
# The grouping in which this couchbase cluster lives (necessary)
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

class couchbase::config (
  $size         = 1024,
  $user         = $::couchbase::user,
  $password     = $::couchbase::password,
  $server_group = 'default',
  $ensure       = $::couchbase::ensure,
  $autofailover = $::couchbase::params::autofailover,

) {

  include ::couchbase::params

  if $autofailover == false {
    $_autofailover = 0
  } else {
    $_autofailover = 1
  }

  # Intitialize a script file
  concat { $::couchbase::params::node_init_script:
    owner => '0',
    group => '0',
    mode  => '0655',
  }


  # Node_init (configure data directory location, etc - be careful to change it will destroy current data)
  if $ensure == present {
    concat::fragment { "${server_group}_couchbase_server_${name}_node_init":
        order   => "15-${server_group}-${::server_name}-node-init",
        target  => $::couchbase::params::node_init_script,
        content => template('couchbase/couchbasenode_init.erb'),
    }
  }
  else {
    concat::fragment { "${server_group}_couchbase_server_${name}_node_init":
      order   => "15-${server_group}-${::server_name}-node-init",
      target  => $::couchbase::params::node_init_script,
      content => "#!/bin/bash\necho 'Skip Init - removing node from cluster.'",
    }
  }

  exec { 'couchbase-node-init':
    path      => ['/opt/couchbase/bin', '/usr/bin', '/bin', '/sbin', '/usr/sbin' ],
    command   => $::couchbase::params::node_init_script,
    require   => [ Class['couchbase::install'] ],
    creates   => $::couchbase::params::node_init_lock,
    logoutput => true,
    tries     => 5,
    try_sleep => 10,
    notify    => Exec['couchbase-init'],
  }


  # Cluster_init (configure memory, etc)

  # Initialize a script file
  concat { $::couchbase::params::cluster_init_script:
    owner => '0',
    group => '0',
    mode  => '0655',
  }

  concat::fragment { '00_cluster_init_script_header':
    target  => $::couchbase::params::cluster_init_script,
    order   => '01',
    content => template('couchbase/couchbase-cluster-setup.sh.erb'),
  }

  concat::fragment { "${server_group}_couchbase_server_${name}_init":
      order   => "15-${server_group}-${::server_name}-init",
      target  => $::couchbase::params::cluster_init_script,
      content => template('couchbase/couchbase-cluster-init.sh.erb'),
      notify  => Exec['couchbase-init'],
  }

  exec { 'couchbase-init':
    path        => ['/opt/couchbase/bin', '/usr/bin', '/bin', '/sbin', '/usr/sbin' ],
    command     => $::couchbase::params::cluster_init_script,
    require     => [ Class['couchbase::install'], Exec['couchbase-node-init']],
    logoutput   => true,
    tries       => 5,
    try_sleep   => 10,
    refreshonly => true,
    notify      => Exec['couchbase-cluster-setup'],
  }

  # Initialize the cluster-building script
  concat { $::couchbase::params::cluster_script:
    owner => '0',
    group => '0',
    mode  => '0655',
  }

  concat::fragment { '00_script_header':
    target  => $::couchbase::params::cluster_script,
    order   => '01',
    content => template('couchbase/couchbase-cluster-setup.sh.erb'),
    notify  => Exec['couchbase-cluster-setup'],
  }

  # Collect cluster node entries for config (from stored configs & PuppetDB)
  Couchbase::Couchbasenode <<| server_group == $server_group |>> ->


  exec { 'couchbase-cluster-setup':
    path        => ['/usr/local/bin', '/usr/bin/', '/sbin', '/bin', '/usr/sbin',
                  '/opt/couchbase/bin'],
    cwd         => '/usr/local/bin',
    command     => 'couchbase-cluster-setup.sh',
    require     => [ Concat[$::couchbase::params::cluster_script], Exec['couchbase-init'] ],
    returns     => [0, 2],
    logoutput   => true,
    refreshonly => true,
  }
}
