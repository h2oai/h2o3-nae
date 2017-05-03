#!/bin/bash

#cp /etc/JARVICE/nodes /opt/flatfile.txt
#sed -e 's/$/:54321/' -i /opt/flatfile.txt

cat /etc/JARVICE/nodes | while read n;
do
  echo "Starting node $n"
  /opt/sssh nimbix@$n /opt/make-flatfile.sh &
  /opt/sssh nimbix@$n /opt/start-h2o3.sh &
done

# Change Nginx Redirect
sed -e 's/8888/54321/' -i /etc/nginx/sites-enabled/default
sed -e 's/8888/54321/' -i /etc/nginx/sites-enabled/notebook-site

# Start Notebook
/usr/local/bin/nimbix_notebook

# Start RStudio
/etc/init.d/rstudio-server restart
