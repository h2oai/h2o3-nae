FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04
MAINTAINER Nimbix, Inc. <support@nimbix.net>

# base OS
ENV DEBIAN_FRONTEND noninteractive
ADD https://github.com/nimbix/image-common/archive/master.zip /tmp/nimbix.zip
WORKDIR /tmp
RUN apt-get update && apt-get -y install sudo zip unzip && unzip nimbix.zip && rm -f nimbix.zip
RUN /tmp/image-common-master/setup-nimbix.sh
RUN touch /etc/init.d/systemd-logind && apt-get -y install module-init-tools xz-utils vim openssh-server libpam-systemd libmlx4-1 libmlx5-1 iptables infiniband-diags build-essential curl libibverbs-dev libibverbs1 librdmacm1 librdmacm-dev rdmacm-utils libibmad-dev libibmad5 byacc flex git cmake screen grep && apt-get clean && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Install Oracle Java 7
RUN \
DEBIAN_FRONTEND=noninteractive apt-get install -y wget python-pip python-sklearn python-pandas python-numpy python-matplotlib software-properties-common python-software-properties && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update -q && \
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer && \
apt-get clean && \
rm -rf /var/cache/apt/*


# Fetch h2o latest_stable
EXPOSE 54321
RUN \
wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
wget --no-check-certificate -i latest -O /opt/h2o.zip && \
unzip -d /opt /opt/h2o.zip && \
rm /opt/h2o.zip && \
cd /opt && \
cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
cp h2o.jar /opt && \
/usr/bin/pip install --upgrade pip && \
/usr/bin/pip install `find . -name "*.whl"`

COPY scripts/start.sh start.sh

# Nimbix JARVICE emulation
EXPOSE 22
RUN mkdir -p /usr/lib/JARVICE && cp -a /tmp/image-common-master/tools /usr/lib/JARVICE
RUN cp -a /tmp/image-common-master/etc /etc/JARVICE && chmod 755 /etc/JARVICE && rm -rf /tmp/image-common-master
RUN mkdir -m 0755 /data && chown nimbix:nimbix /data
RUN sed -ie 's/start on.*/start on filesystem/' /etc/init/ssh.conf

