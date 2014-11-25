puppet-couchbase: Scalable couchbase module
===============================================

This module can install couchbase on servers, create buckets
and automatically maintain the cluster.

Usage
-----

Install a couchbase server with a standard user/password::

    class { 'couchbase':
        size     => 1024,
        user     => 'couchbase',
        password => 'password',
        version  => latest,
    }

Create a couchbase bucket (Note the user/password)::

    couchbase::bucket { 'memcached':
        port     => 11211,
        size     => 1024,
        user     => 'couchbase',
        password => 'password',
        type     => 'memcached',
        replica  => 1
    }

Install the SDK for your language (currently supported ruby and python)::

    couchbase::client { 'ruby': }

Using it with an unsupported language will install the libcouchbase-devel and
libcouchbase2-libevent which are required for any other SDK. So for example if you want
to install your php client you should use this to install the required libs and then
install the php pecl couchbase extension using another module. Don't forget to define
your relationships which in the case of module example42/php could look like::

    Class['Couchbase'] -> Couchbase::Client <| |> -> Class['Php'] -> Php::Pecl::Module <| |>

You can add a moxi listener on Windows machines now. It is a resource define so can be added like so:

    couchbase::moxi { 'default':
      nodes => ['127.0.0.1:8091'],
    }

For more details about Moxi: http://docs.couchbase.com/moxi-manual-1.8/

Notes
-----

This module uses a puppetdb installation (it is actually required) to generate a set of
server installation files. These will run on any new node added to the cluster.
What this means is that transparently you can add nodes to a Couchbase server group.
This could be done via auto-scaling or other methods, as long as they all are assigned to
the same server group.

Due to this, the module requires the mentioned puppetdb services as well as storeconfigs,
puppetlabs/concat and puppetlabs/stdlib.

TODO
----

+ Add the ability to do cleanup of nodes from cluster
+ Build tests into module
