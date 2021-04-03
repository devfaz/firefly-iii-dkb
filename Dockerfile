FROM debian

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev && \
  apt-get clean

RUN echo && \
  git clone --single-branch https://github.com/aqbanking/gwenhywfar.git /usr/src/gwenhywfar && \
  cd /usr/src/gwenhywfar && \
  make -fMakefile.cvs && \
  ./configure --prefix=/ --exec-prefix=/usr --with-guis="" && \
  make && \
  make install && \
  git clone --single-branch https://github.com/aqbanking/aqbanking /usr/src/aqbanking && \
  cd /usr/src/aqbanking && \
  make -fMakefile.cvs && \
  ./configure --prefix=/ --exec-prefix=/usr --with-xmlmerge=/usr/bin/xmlmerge && \
  make typedefs && \
  make types && \
  make && \
  make install && \
  rm -R /usr/src/*


COPY gencsv.sh /usr/local/bin/

RUN useradd --uid 1000 aqbanking && \
  chmod +x /usr/local/bin/ -R

