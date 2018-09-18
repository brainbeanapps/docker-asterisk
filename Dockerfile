FROM centos:7

LABEL maintainer="technical@brainbeanapps.com"

ARG LIBJANSSON_VERSION=2.11
ARG DAHDI_VERSION="2.11.1+2.11.1"
ARG ASTERISK_VERSION=13.23.0
ARG ASTERISK_DEPENDENCIES=""
ARG ASTERISK_BUILD_DEPENDENCIES=""
ARG ASTERISK_MODULES="--with-pjproject-bundled"
ARG ASTERISK_OPTIONS="--enable format_mp3 --enable app_confbridge"

# Install updates, enable EPEL, install dependencies
RUN yum -y update && \
  yum -y install epel-release && \
  yum -y install python openssl-libs file unzip bzip2 && \
  yum clean all && \
  rm -rf /var/cache/yum

# Compile & install libjansson
WORKDIR /tmp/libjansson
RUN curl -fsSLo /tmp/libjansson.tar.gz http://www.digip.org/jansson/releases/jansson-${LIBJANSSON_VERSION}.tar.gz && \
  tar -xzf /tmp/libjansson.tar.gz -C . --strip-components=1 && \
  yum -y install autoconf make gcc gcc-c++ && \
  ./configure --prefix=/usr && \
  make && \
  make check && \
  make install && \
  yum -y remove autoconf make gcc gcc-c++ && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/libjansson && \
  rm -f /tmp/libjansson.tar.gz

# Compile & install DAHDI
WORKDIR /tmp/dahdi
RUN curl -fsSLo /tmp/dahdi.tar.gz https://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-${DAHDI_VERSION}.tar.gz && \
  tar -xzf /tmp/dahdi.tar.gz -C . --strip-components=1 && \
  yum -y install autoconf make gcc gcc-c++ kernel-devel && \
  KSRC=$(cd /usr/src/kernels/* && pwd) make && \
  KSRC=$(cd /usr/src/kernels/* && pwd) make install && \
  KSRC=$(cd /usr/src/kernels/* && pwd) make config && \
  yum -y remove autoconf make gcc gcc-c++ kernel-devel && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/dahdi && \
  rm -f /tmp/dahdi.tar.gz

# Compile & install libpri
WORKDIR /tmp/libpri
RUN curl -fsSLo /tmp/libpri.tar.gz https://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz && \
  tar -xzf /tmp/libpri.tar.gz -C . --strip-components=1 && \
  yum -y install autoconf make gcc gcc-c++ && \
  make && \
  make install && \
  yum -y remove autoconf make gcc gcc-c++ && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/libpri && \
  rm -f /tmp/libpri.tar.gz

# Compile & install libiksemel (for Google Voice)
WORKDIR /tmp/libiksemel
RUN curl -fsSLo /tmp/libiksemel.zip https://github.com/meduketto/iksemel/archive/master.zip && \
  unzip /tmp/libiksemel.zip -d /tmp && \
  mv /tmp/iksemel-master/* . && \
  yum -y install autoconf make gcc gcc-c++ libtool python-devel texinfo && \
  ./autogen.sh && \
  ./configure --prefix=/usr && \
  make && \
  make install && \
  yum -y remove autoconf make gcc gcc-c++ libtool python-devel texinfo && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/libiksemel && \
  rm -f /tmp/libiksemel.zip

# Compile & install libsrtp2
WORKDIR /tmp/libsrtp2
RUN curl -fsSLo /tmp/libsrtp2.tar.gz http://github.com/cisco/libsrtp/archive/v2.tar.gz && \
  tar -xzf /tmp/libsrtp2.tar.gz -C . --strip-components=1 && \
  yum -y install autoconf make gcc gcc-c++ openssl-devel && \
  ./configure --prefix=/usr --enable-openssl && \
  make shared_library && \
  make install && \
  yum -y remove autoconf make gcc gcc-c++ openssl-devel && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/libsrtp2 && \
  rm -f /tmp/libsrtp2.tar.gz

# Compile & install Asterisk
WORKDIR /tmp/asterisk
RUN curl -fsSLo /tmp/asterisk.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz && \
  tar -xzf /tmp/asterisk.tar.gz -C . --strip-components=1 && \
  yum -y install ncurses-libs libuuid libxml2 sqlite libedit speex speexdsp libogg libvorbis alsa-lib portaudio \
    libcurl openldap postgresql-libs unixODBC neon gmime lua uriparser libxslt mariadb-libs bluez-libs radcli freetds \
    jack-audio-connection-kit net-snmp-libs corosynclib newt popt libical spandsp uw-imap binutils \
    gsm doxygen graphviz zlib hoard codec2 fftw-libs libsndfile unbound-libs opus mISDN \
    ${ASTERISK_DEPENDENCIES} \
    && \
  yum -y install autoconf make gcc gcc-c++ flex bison patch subversion ncurses-devel libuuid-devel libxml2-devel \
    sqlite-devel libedit-devel speex-devel libogg-devel libvorbis-devel alsa-lib-devel portaudio-devel \
    libcurl-devel openldap-devel postgresql-devel unixODBC-devel neon-devel gmime-devel lua-devel uriparser-devel \
    libxslt-devel openssl-devel mariadb-devel bluez-libs-devel radcli-devel freetds-devel \
    jack-audio-connection-kit-devel net-snmp-devel corosynclib-devel newt-devel popt-devel libical-devel spandsp-devel \
    uw-imap-devel binutils-devel gsm-devel zlib-devel codec2-devel fftw-devel libsndfile-devel \
    unbound-devel opus-devel mISDN-devel \
    ${ASTERISK_BUILD_DEPENDENCIES} \
    && \
  ./configure ${ASTERISK_MODULES} && \
  contrib/scripts/get_mp3_source.sh && \
  make menuselect.makeopts && \
  menuselect/menuselect ${ASTERISK_OPTIONS} menuselect.makeopts && \
  make && \
  make install && \
  make config && \
  yum -y remove autoconf make gcc gcc-c++ flex bison patch subversion ncurses-devel libuuid-devel libxml2-devel \
    sqlite-devel libedit-devel speex-devel libogg-devel libvorbis-devel alsa-lib-devel portaudio-devel \
    libcurl-devel openldap-devel postgresql-devel unixODBC-devel neon-devel gmime-devel lua-devel uriparser-devel \
    libxslt-devel openssl-devel mariadb-devel bluez-libs-devel radcli-devel freetds-devel \
    jack-audio-connection-kit-devel net-snmp-devel corosynclib-devel newt-devel popt-devel libical-devel spandsp-devel \
    uw-imap-devel binutils-devel gsm-devel zlib-devel codec2-devel fftw-devel libsndfile-devel \
    unbound-devel opus-devel mISDN-devel \
    ${ASTERISK_BUILD_DEPENDENCIES} \
    && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/asterisk && \
  rm -f /tmp/asterisk.tar.gz

ENTRYPOINT [ "/usr/sbin/asterisk", "-cvvvvv" ]
