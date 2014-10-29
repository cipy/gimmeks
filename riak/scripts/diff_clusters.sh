#!/bin/bash

# Description: lists bucket/keys at source and destination, then counts unreplicated keys at destination
#
# Usage: $0 <source-riak-hostname>:<http-port> <destination-riak-hostname>:<http-port> <bucket-to-test>
#
# Requires: riak, curl, sort, comm


# exit if any required parameters are missing
[ -z "$1" -o -z "$2" -o -z "$3" ] && exit 10

sourceRiak="$1"
destinationRiak="$2"
bucket="$3"

# reserve temporary filenames for our processes
srcKeysFile=$(mktemp /tmp/riak-source-keys-XXXX)
destKeysFile=$(mktemp /tmp/riak-destination-keys-XXXX)


echo -n "Starting async listing of keys at source, pid: "
curl -s "http://$sourceRiak/buckets/$bucket/keys?keys=stream" | sed -E -e 's/","/\n/g' -e 's/"\]\}\{"/\n/g' -e 's/":\["/\n/g' | grep -v keys > $srcKeysFile &
srcCurlPID=$!
echo $srcCurlPID

# the Chuck Norris's way of parsing JSONs

echo -n "Starting async listing of keys at destination, pid: "
curl -s "http://$destinationRiak/buckets/$bucket/keys?keys=stream" | sed -E -e 's/","/\n/g' -e 's/"\]\}\{"/\n/g' -e 's/":\["/\n/g' | grep -v keys > $destKeysFile &
destCurlPID=$!
echo $destCurlPID


echo "Waiting for keys streaming to complete at source and destination"
wait $srcCurlPID $destCurlPID

keysAtSource=$(wc -l $srcKeysFile | cut -d" " -f1)
keysAtDestination=$(wc -l $destKeysFile | cut -d" " -f1)

echo "Keys at source: $keysAtSource"
echo "Keys at destination: $keysAtDestination"


# reserve temporary filenames for our processes
srcSortFile=$(mktemp /tmp/riak-source-sorted-XXXX)
destSortFile=$(mktemp /tmp/riak-destination-sorted-XXXX)

echo "Sorting source and destination keys"
cat $srcKeysFile | sort > $srcSortFile
cat $destKeysFile | sort > $destSortFile

countMissing=$(comm $srcSortFile $destSortFile -2 | wc -l)
echo "Looks like $countMissing keys from source are not yet replicated at the destination"


# cleanup, remove all temporary files
rm -f $srcKeysFile $destKeysFile
rm -f $srcSortFile $destSortFile

