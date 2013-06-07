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

Notes
-----

This module uses a puppetdb installation (it is actually required) to generate a set of
server installation files. These will run on any new node added to the cluster.
What this means is that transparently you can add nodes to a Couchbase server group.
This could be done via auto-scaling or other methods, as long as they all are assigned to
the same server group.

Due to this, the module requires the mentioned puppetdb services as well as storeconfigs
and concat.

TODO
----

+ Add the ability to do cleanup of nodes from cluster
+ Build tests into module 
