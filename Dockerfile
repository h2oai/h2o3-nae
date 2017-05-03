FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04
MAINTAINER H2o.ai <ops@h2o.ai>

# Nimbix base OS
ENV DEBIAN_FRONTEND noninteractive

# Setup Repos
RUN \
  apt-get -y update && \
  apt-get install -y \
  apt-utils \
  software-properties-common \
  python-software-properties
  
RUN \  
  echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" | sudo tee -a /etc/apt/sources.list && \
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
  gpg -a --export E084DAB9 | apt-key add -&& \
  curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
  add-apt-repository -y ppa:webupd8team/java && \
  add-apt-repository ppa:chris-lea/zeromq && \
  add-apt-repository ppa:chris-lea/libsodium && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN \
  apt-get -y update && \
  apt-get -y install \
  curl \
  python3-setuptools \
  python3-pip \
  wget \
  gdebi \
  python3-pandas \
  python3-numpy \
  python3-matplotlib \
  libxml2-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
  libgtk2.0-0 \
  nodejs \
  libsodium-dev \
  libzmq5 \
  libzmq5-dev \
  iputils-ping
  
# Nimbix Common
RUN \
  curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh | bash

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

# Notebook Common
ADD https://raw.githubusercontent.com/nimbix/notebook-common/master/install-ubuntu.sh /tmp/install-ubuntu.sh
RUN \
  bash /tmp/install-ubuntu.sh 3 && \
  rm -f /tmp/install-ubuntu.sh

# Get R
RUN \
  apt-get install -y r-base r-base-dev && \
  wget https://cran.cnr.berkeley.edu/src/contrib/data.table_1.10.4.tar.gz && \
  wget https://cran.cnr.berkeley.edu/src/contrib/lazyeval_0.2.0.tar.gz && \
  wget https://cran.cnr.berkeley.edu/src/contrib/Rcpp_0.12.10.tar.gz && \
  wget https://cran.cnr.berkeley.edu/src/contrib/tibble_1.3.0.tar.gz && \
  wget https://cran.cnr.berkeley.edu/src/contrib/hms_0.3.tar.gz && \
  wget https://cran.cnr.berkeley.edu/src/contrib/feather_0.3.1.tar.gz && \
  R CMD INSTALL \
  data.table_1.10.4.tar.gz \
  lazyeval_0.2.0.tar.gz \
  Rcpp_0.12.10.tar.gz \
  tibble_1.3.0.tar.gz \
  hms_0.3.tar.gz \
  feather_0.3.1.tar.gz

# Install Oracle Java 8
RUN \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

# Install RStudio
RUN \
  wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb && \
  gdebi -n rstudio-server-1.0.143-amd64.deb && \
  rm rstudio-server-1.0.143-amd64.deb

# Install H2o
RUN \
  wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
  wget --no-check-certificate -i latest -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
  cp h2o.jar /opt
  
# Install Python Dependancies
RUN \
  /usr/bin/pip3 install --upgrade pip && \
  cd /opt && \
  /usr/bin/pip3 install `find . -name "*.whl"`

# Copy bash scripts
COPY scripts/start-h2o3.sh /opt/start-h2o3.sh
COPY scripts/make-flatfile.sh /opt/make-flatfile.sh
COPY scripts/start-cluster.sh /opt/start-cluster.sh

# Set executable on scripts
RUN \
  chown -R nimbix:nimbix /opt && \
  chmod +x /opt/start-h2o3.sh && \
  chmod +x /opt/make-flatfile.sh && \
  chmod +x /opt/start-cluster.sh

# Nimbix Integrations
ADD ./NAE/AppDef.json /etc/NAE/AppDef.json
ADD ./NAE/AppDef.png /etc//NAE/default.png
ADD ./NAE/screenshot.png /etc/NAE/screenshot.png


