#!/bin/bash

# Description: simple hack to stream and remove older KVs from riak
#
# Usage: $0 <remove-KVs-older-than-days> <from-target-bucket>
#
# Requires: riak running on the localhost (or behind a local haproxy)
# ATTN: do *NOT* run this code against riak releases prior to 1.4.8!


# exit if any required parameters are missing
[ -z "$1" -o -z "$2" ] && exit 10

days="$1"
riakIP="127.0.0.1"
bucket="$2"

# or maybe riak/haproxy is listening on eth0, then grab its IP
#riakIP=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1)

# stream keys, strip JSON (don't mind the accidental "keys" tokens) and pipe them to 100 local ./del_key_older.sh processes
curl -m 300 -s "http://$riakIP:8098/buckets/$bucket/keys?keys=stream" | sed -E -e 's/","/\n/g' -e 's/"\]\}\{"/\n/g' -e 's/":\["/\n/g' | xargs -n 1 -P 100 ./del_key_older.sh $days $bucket
