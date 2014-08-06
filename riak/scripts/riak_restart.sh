#!/bin/bash

# PLEASE NOTE
#
# while this script has some safety measures (won't restart the node if other(s) are down)
# you should *always* use `ansible -f 1 ...` for a gentle / rolling restart of the cluster


# drop the ball if riak/riak-admin are not found
[ -f /etc/riak/vm.args ] || exit 1
which riak-admin || exit 1

sudo riak-admin transfer-limit | grep offline &>/dev/null
ret=$?

# exit if any (riak) nodes are down
[ $ret -ne 1 ] && exit 2

sudo /etc/init.d/riak stop
sudo /etc/init.d/riak start

node_name=$(head /etc/riak/vm.args | grep -E '^-name' | tr -s " " | cut -d" " -f2)

sudo riak-admin wait-for-service riak_kv $node_name
