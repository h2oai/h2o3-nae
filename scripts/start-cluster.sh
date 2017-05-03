#!/bin/bash

cp /etc/JARVICE/nodes /opt/flatfile.txt
sed -e 's/$/:54321/' -i /opt/flatfile.txt


for i in `tail -n +2 /etc/JARVICE/nodes`; do 
   scp /opt/flatfile.txt $i:/opt/flatfile.txt 
   ssh $i "/opt/start-h2o3.sh" 
done 

