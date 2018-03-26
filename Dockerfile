FROM nvidia/cuda:9.0-cudnn7-runtime
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
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

# Get R
WORKDIR /opt

# Install Oracle Java 8
RUN \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

# Install H2o
RUN \
  wget --no-check-certificate http://h2o-release.s3.amazonaws.com/h2o/rel-wolpert/4/h2o-3.18.0.4.zip -O /opt/h2o-latest.zip && \
  unzip -d /opt /opt/h2o-latest.zip && \
  rm /opt/h2o-latest.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
  cp h2o.jar /opt && \

EXPOSE 54321
  
# Copy bash scripts
COPY scripts/start-h2o3.sh /opt/start-h2o3.sh
COPY scripts/make-flatfile.sh /opt/make-flatfile.sh
COPY scripts/start-cluster.sh /opt/start-cluster.sh
COPY scripts/sssh /opt/sssh

# Set executable on scripts
RUN \
  chown -R nimbix:nimbix /opt && \
  chmod +x /opt/start-h2o3.sh && \
  chmod +x /opt/make-flatfile.sh && \
  chmod +x /opt/start-cluster.sh && \
  chmod +x /opt/sssh 

# Nimbix Integrations
ADD ./NAE/AppDef.json /etc/NAE/AppDef.json
ADD ./NAE/AppDef.png /etc//NAE/default.png
ADD ./NAE/screenshot.png /etc/NAE/screenshot.png
