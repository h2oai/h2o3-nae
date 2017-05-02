#!/bin/bash

sudo /sbin/init

cp /etc/JARVICE/nodes /opt/flatfile.txt
sed -e 's/$/:54321/' -i /opt/flatfile.txt

cat /etc/JARVICE/nodes | while read n;
do
  echo "Starting node $n"
  scp flatfile.txt nimbix@$n:/opt/flatfile.txt
  ssh nimbix@$n /opt/start-h2o3.sh &
done
