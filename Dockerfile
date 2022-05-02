FROM debian

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext && \
  apt-get clean

RUN echo && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/411/gwenhywfar-5.8.2.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/400/aqbanking-6.4.1.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  cd /usr/src/gwenhywfar* && \
  make -fMakefile.cvs && \
  ./configure --prefix=/ --exec-prefix=/usr --with-guis="" && \
  make && \
  make install && \
  cd /usr/src/aqbanking* && \
  make -fMakefile.cvs && \
  ./configure --prefix=/ --exec-prefix=/usr --with-xmlmerge=/usr/bin/xmlmerge && \
  make typedefs && \
  make types && \
  make && \
  make install && \
  rm -R /usr/src/*


COPY gencsv.sh /usr/local/bin/
COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 aqbanking && \
  chmod +x /usr/local/bin/ -R

