FROM phusion/baseimage
MAINTAINER Dan Osborne <dan@projectcalico.org>

# Install Dependencies

RUN apt-get update -q --fix-missing
RUN apt-get -qy install software-properties-common # (for add-apt-repository)
RUN add-apt-repository ppa:george-edison55/cmake-3.x
RUN apt-get update -q
RUN apt-cache policy cmake
RUN apt-get -qy install \
  build-essential                         \
  autoconf                                \
  automake                                \
  cmake=3.2.2-2~ubuntu14.04.1~ppa1 \
  ca-certificates                         \
  gdb                                     \
  wget                                    \
  git-core                                \
  libcurl4-nss-dev                        \
  libsasl2-dev                            \
  libtool                                 \
  libsvn-dev                              \
  libapr1-dev                             \
  libgoogle-glog-dev                      \
  libboost-dev                            \
  protobuf-compiler                       \
  libprotobuf-dev                         \
  make                                    \
  python                                  \
  python2.7                               \
  libpython-dev                           \
  python-dev                              \
  python-protobuf                         \
  python-setuptools                       \
  heimdal-clients                         \
  libsasl2-modules-gssapi-heimdal         \
  unzip                                   \
  dnsutils                                \
  --no-install-recommends

# Install the picojson headers
RUN wget https://raw.githubusercontent.com/kazuho/picojson/v1.3.0/picojson.h -O /usr/local/include/picojson.h

# Prepare to build Mesos
RUN mkdir -p /mesos
RUN mkdir -p /tmp
RUN mkdir -p /usr/share/java/
RUN wget http://search.maven.org/remotecontent?filepath=com/google/protobuf/protobuf-java/2.5.0/protobuf-java-2.5.0.jar -O protobuf.jar
RUN mv protobuf.jar /usr/share/java/

WORKDIR /mesos

# Clone Mesos (master branch)
RUN git clone https://github.com/djosborne/mesos.git /mesos
RUN git checkout strip-subnet-for-cni 
RUN git log -n 1

# Bootstrap
RUN ./bootstrap

# Configure
RUN mkdir build && cd build && ../configure --disable-java --disable-optimize --without-included-zookeeper

# Build Mesos
RUN cd build && make -j 2 install

# Install python eggs
RUN easy_install /mesos/build/src/python/dist/mesos.interface-*.egg
RUN easy_install /mesos/build/src/python/dist/mesos.executor-*.egg
RUN easy_install /mesos/build/src/python/dist/mesos.scheduler-*.egg
RUN easy_install /mesos/build/src/python/dist/mesos.native-*.egg


###################
# Docker
###################
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    python-dev python-pip

RUN pip install --upgrade pip

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Define additional metadata for our image.
VOLUME /var/lib/docker


####################
# Mesos-DNS
####################
RUN curl -LO https://github.com/mesosphere/mesos-dns/releases/download/v0.5.0/mesos-dns-v0.5.0-linux-amd64 && \
    mv mesos-dns-v0.5.0-linux-amd64 /usr/bin/mesos-dns && \
    chmod +x /usr/bin/mesos-dns

####################
# Demo Files
####################
# redis
WORKDIR /root
RUN curl -LO http://download.redis.io/releases/redis-3.2.0.tar.gz
RUN tar -xvf /root/redis-3.2.0.tar.gz
WORKDIR /root/redis-3.2.0
RUN make && make install

# flask
RUN pip install flask redis
ADD ./demo/app.py /root/

#################
# Init scripts
#################
ADD ./init_scripts/etc/service/mesos_slave/run /etc/service/mesos_slave/run
ADD ./init_scripts/etc/service/docker/run /etc/service/docker/run
ADD ./init_scripts/etc/service/calico/run /etc/service/calico/run
ADD ./init_scripts/etc/service/mesos-dns/run /etc/service/mesos-dns/run
ADD ./init_scripts/etc/config/mesos-dns.json /etc/config/mesos-dns.json


######################
# Calico
######################
COPY ./calico/ /calico/
RUN curl -L -o /usr/local/bin/calicoctl https://github.com/projectcalico/calico-docker/releases/download/v0.19.0/calicoctl
RUN chmod +x /usr/local/bin/calicoctl


ADD ./cni/ /cni/
