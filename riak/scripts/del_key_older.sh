#!/bin/bash

# Description: Simple logic to detect and remove KV older than N days
#
# Usage: $0 <older-than-days> <in-bucket> <key-to-test>
#
# Requires: riak running on the localhost (or behind a local haproxy)


# exit if any required parameters are missing
[ -z "$1" -o -z "$2" -o -z "$3" ] && exit 10

daysInSeconds=$((3600*24*$1))
riakIP="127.0.0.1"
bucket="$2"
key="$3"

# or maybe riak/haproxy is listening on eth0, then grab its IP
#riakIP=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1)

curl_out=$(curl -Is "$riakIP:8098/buckets/$bucket/keys/$key")
rc=$?

# exit if curl failed
[ $rc -ne 0 ] && exit 1

grep_out=$(echo "$curl_out" | grep "Last-Modified:" 2>/dev/null)
rc=$?

# exit if grep failed
[ $rc -ne 0 ] && exit 2

old_stamp=$(echo "$grep_out" | sed -E 's/^Last-Modified:\s+//')
date_out=$(date -d "$old_stamp" "+%s" 2>&1)
rc=$?

# exit if date(?) failed
[ $rc -ne 0 ] && exit 3

old_time=$date_out
err_time=$(date -d "1 Jan 2010" "+%s")

# hmm, do you really have data that old?
[ $old_time -lt $err_time ] && exit 4

now_time=$(date +%s)
delta=$((now_time-old_time))

# delete the key older than $1 days
[ $delta -gt $daysInSeconds ] && curl -s -X DELETE "http://$riakIP:8098/buckets/$bucket/keys/$key"

