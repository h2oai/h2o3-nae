#!/bin/bash

# Change Nginx Redirect
sudo sed -e 's/8888/8787/' -i /etc/nginx/sites-enabled/default
sudo sed -e 's/8888/8787/' -i /etc/nginx/sites-enabled/notebook-site

# Start SSH
sudo system ssh restart
# Start RStudio
sudo service nginx restart

sudo /etc/init.d/rstudio-server restart
