#!/bin/bash

cat nodes | while read n;
do
  echo "Starting node $n"
  scp flatfile.txt nimbix@$n:/opt/flatfile.txt
  ssh nimbix@$n /opt/start-h2o3.sh &
done
