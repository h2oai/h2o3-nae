FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER H2o.ai <ops@h2o.ai>

# Nimbix base OS
ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get -y update && \
  apt-get install -y \
  curl \
  wget

# Nimbix Common
RUN \
  curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh | bash

EXPOSE 22

# Notebook Common
ADD https://raw.githubusercontent.com/nimbix/notebook-common/master/install-ubuntu.sh /tmp/install-ubuntu.sh
RUN \
  bash /tmp/install-ubuntu.sh 3 && \
  rm -f /tmp/install-ubuntu.sh

# Setup Repos
RUN \
  apt-get install -y \
  apt-utils \
  software-properties-common \
  python-software-properties
  
RUN \  
  echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list && \
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
  gpg -a --export E084DAB9 | apt-key add -&& \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN \
  apt-get -y update && \
  apt-get -y install \
  python3-setuptools \
  python3-pip \
  gdebi \
  python3-pandas \
  python3-numpy \
  python3-matplotlib \
  libxml2-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
  libgtk2.0-0 \
  iputils-ping
  
# Get R
WORKDIR /opt

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
    feather_0.3.1.tar.gz && \
    rm -rf *.tar.gz && \
  R -e 'chooseCRANmirror(graphics=FALSE, ind=54);install.packages(c("R.utils",  "RCurl", "jsonlite", "statmod", "devtools", "roxygen2", "testthat", "Rcpp", "fpc", "RUnit", "ade4", "glmnet", "gbm", "ROCR", "e1071", "ggplot2", "LiblineaR"))'

# Install RStudio
RUN \
  wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb && \
  gdebi -n rstudio-server-1.0.143-amd64.deb && \
  rm rstudio-server-1.0.143-amd64.deb

EXPOSE 8787

# Install Oracle Java 8
RUN \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

# Install H2o
RUN \
  wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
  wget --no-check-certificate -i latest -O /opt/h2o-latest.zip && \
  unzip -d /opt /opt/h2o-latest.zip && \
  rm /opt/h2o-latest.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
  cp h2o.jar /opt && \
  R CMD INSTALL `find . -name "h2o*.tar.gz"` && \
  /usr/bin/pip3 install --upgrade pip && \
  cd /opt && \
  /usr/bin/pip3 install `find . -name "*.whl"`

EXPOSE 54321
  
# Copy bash scripts
COPY scripts/start-h2o3.sh /opt/start-h2o3.sh
COPY scripts/make-flatfile.sh /opt/make-flatfile.sh
COPY scripts/start-cluster.sh /opt/start-cluster.sh
COPY scripts/start-rstudio.sh /opt/start-rstudio.sh
COPY scripts/sssh /opt/sssh

# Set executable on scripts
RUN \
  chown -R nimbix:nimbix /opt && \
  chmod +x /opt/start-h2o3.sh && \
  chmod +x /opt/make-flatfile.sh && \
  chmod +x /opt/start-cluster.sh && \
  chmod +x /opt/start-rstudio.sh && \
  chmod +x /opt/sssh 

# Nimbix Integrations
ADD ./NAE/AppDef.json /etc/NAE/AppDef.json
ADD ./NAE/AppDef.png /etc//NAE/default.png
ADD ./NAE/screenshot.png /etc/NAE/screenshot.png
