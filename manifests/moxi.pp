define couchbase::moxi (
  $port            = $::couchbase::params::moxi_port,
  $version         = $::couchbase::params::moxi_version,
  $bucket          = $name,
  $cluster_urls    = ['http://127.0.0.1:8091/pools/default/bucketsStreaming/default'],
  $nodes           = ['127.0.0.1:8091'],
) {

  # TODO: Add port check (isinteger)
  include couchbase::params

  if $::couchbase::ensure == present {
    
    # Class['couchbase::bucket'] -> Couchbase::moxi
      
      $pkgname = "moxi-server_${version}_x86_64.${couchbase::params::pkgtype}"      
      $pkgsource = "http://packages.couchbase.com/releases/${version}/${pkgname}" 
      $options = "port_listen=${port},
                  default_bucket_name=${bucket},
                  downstream_max=1024,
                  downstream_conn_max=4,
                  connect_max_errors=5,
                  connect_retry_interval=30000,
                  connect_timeout=400,
                  auth_timeout=100,cycle=200,
                  downstream_conn_queue_timeout=200,
                  downstream_timeout=5000,
                  wait_queue_timeout=200"
     
    
    $cluster_config = join($cluster_urls,",")
    
    notify {$cluster_config:}

    file { "/etc/init.d/moxi-server_${port}":
      owner   => 'couchbase',
      group   => 'couchbase',
      mode    => '0755',
      content => template("${module_name}/moxi-init.d.erb"),            
      # require => Package['moxi-server'],      
      notify  => Service["moxi-server_${port}"],
    }


    # TODO: Collect ports and urls of active clusters. but right now:
    file { "/etc/sysconfig/moxi-server_${port}":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "OPTIONS='${options}'
                  CLUSTER_CONFIG='${cluster_config}'
                  PARAMETERS='-vvv'",
      notify  => Service["moxi-server_${port}"],
    }

    service {"moxi-server_${port}":
      ensure => running,
    }
  }
  else {
    notify {"Couchbase is configured to be absent. Moxi can not be configured.":}
  }
  

}
