define couchbase::moxi (
  $port            = $::couchbase::params::moxi_port,
  $version         = $::couchbase::params::moxi_version,
  $bucket          = $name,
  $cluster_urls    = ['http://127.0.0.1:8091/pools/default/bucketsStreaming/default'],
  $nodes           = ['127.0.0.1:8091'],
  $parameters      = ''
) {


  # TODO: Add port check (isinteger)

  # TODO: Add dependency to moxi package installation
  include couchbase::params


  $node_config = "port_listen=${port},default_bucket_name=${bucket},downstream_max=1024,downstream_conn_max=16,connect_max_errors=5,connect_retry_interval=30000,connect_timeout=400,auth_timeout=100,cycle=200,downstream_conn_queue_timeout=200,downstream_timeout=5000,wait_queue_timeout=200"
  
      
  $cluster_config = join($cluster_urls,",")

  if $::kernel == 'Linux' {
    # Linux uses moxi from couchbase bins
    if $::couchbase::ensure == present {    
      # Class['couchbase::bucket'] -> Couchbase::moxi
      
      
      # notify {$cluster_config:}

      file { "/etc/init.d/moxi-server_${port}":
        owner   => 'couchbase',
        group   => 'couchbase',
        mode    => '0755',
        content => template("${module_name}/moxi-init.d.erb"),            
        notify  => Service["moxi-server_${port}"],
      }


      # TODO: Collect ports and urls of active clusters. but right now:
      file { "/etc/sysconfig/moxi-server_${port}":
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "OPTIONS='${node_config}'\n
                    CLUSTER_CONFIG='${cluster_config}'
                    PARAMETERS='-vvv'",
        notify  => Service["moxi-server_${port}"],
      }

      service {"moxi-server_${port}":
        ensure => running,
      }
    }
    else {
      notify {"Couchbase is not configured to be present. Moxi can not be configured.":}
    }

  } elsif $::kernel == 'windows' {
    $moxi_root = 'c:\moxi'
    $moxi_log = "${moxi_root}\log\moxi_${port}.log"

    

    file { "${$moxi_root}\bin\moxi-server_${port}.cmd":
      content => template("${module_name}/moxi-win_service.erb"),      
      require => Package['moxi'],
      notify  => Service["Couchbase Moxi ${bucket} ${port}"],
    }

    # ->
    # notify{"nssm install \"Couchbase Moxi ${bucket} ${port}\" ${moxi_root}\bin\moxi-server_${port}.cmd":}
    

    exec {"register-moxi-service_${port}":
      command => "nssm install \"Couchbase Moxi ${bucket} ${port}\" ${moxi_root}\bin\moxi-server_${port}.cmd",      
      unless => "sc query \"Couchbase Moxi ${bucket} ${port}\"",
      path => $::path,
      require => Package['nssm','moxi'],
    }

    service { "Couchbase Moxi ${bucket} ${port}":
      enable => true,
      ensure => running,
      require => Exec["register-moxi-service_${port}"],
    }
    

  }

  
  

}
