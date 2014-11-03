#!/bin/bash

# Description: rsync's riak partitions from source *only* if they should exist at the destination
#
# Usage: $0 <user@destination-riak-node>
#
# Requires: riak offline at both source/destination; rsync; ssh auth forwarding enabled at source

destRiak="$1"


sourceDir=$(grep data_root /etc/riak/app.config 2>/dev/null | grep leveldb | cut -d\" -f2)
[ -z "$sourceDir" ] && echo "Unable to find a local data_dir on this riak node" # && exit 1

echo -n "Reading destination's data_dir: "
destDir=$(ssh $destRiak 'grep data_root /etc/riak/app.config 2>/dev/null | grep leveldb | cut -d\" -f2')
echo $destDir

echo "Reading destination's partitions..."
destPartitions=$(ssh $destRiak ls $destDir)

for partition in $destPartitions; do
	[ -d "$sourceDir/$partition" ] && echo "Rsyncing $sourceDir/$partition to $destRiak:$destDir/"
	[ -d "$sourceDir/$partition" ] && rsync -e ssh -del -av "$sourceDir/$partition" $destRiak:"$destDir/"
done
