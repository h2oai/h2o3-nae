#!/bin/bash

cat nodes | while read n;
do
  echo "Starting node $n"
  ssh nimbix@$n /opt/make-flatfile.sh 
  ssh nimbix@$n /opt/start-h2o3.sh &
done
