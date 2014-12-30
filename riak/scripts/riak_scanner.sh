#!/bin/bash

# Description: online (streaming) scans of a riak node data
#
# Usage: $0 <riak-ip-address> <riak-http-port>
#
# Requires: riak, pigz, curl


# exit if any required parameters are missing
[ -z "$1" -o -z "$2" ] && exit 10

riakIP="$1"
riakPort="$2"

# reserve temporary filenames for our processes
allBucketsFile=$(mktemp /tmp/riak-$riakIP-buckets-XXXX.gz)


echo "Streaming all buckets from $riakIP:$riakPort"
curl -m 300 -s "http://$riakIP:$riakPort/buckets?buckets=stream" | sed -E -e 's/","/\n/g' -e 's/"\]\}\{"/\n/g' -e 's/":\["/\n/g' | grep -v buckets | pv -r | pigz --fast > $allBucketsFile

for bucket in $(pigz -dc $allBucketsFile); do

	echo "Streaming all keys for $bucket"

	allKeysFile=$(mktemp /tmp/riak-$riakIP-$bucket-keys-XXXX.gz)
	curl -m 300 -s "http://$riakIP:$riakPort/buckets/$bucket/keys?keys=stream" | sed -E -e 's/","/\n/g' -e 's/"\]\}\{"/\n/g' -e 's/":\["/\n/g' | grep -v keys | pv -r | pigz --fast > $allKeysFile

	echo "Found $(pigz -dc $allKeysFile | wc -l) keys in $bucket" 
done


# cleanup, remove all temporary files, see /tmp/riak-*
