FROM debian@sha256:b91baba9c2cae5edbe3b0ff50ae8f05157e3ae6f018372dcfc3aba224acb392b

LABEL org.opencontainers.image.source = "https://github.com/devfaz/firefly-iii-dkb"

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext && \
  apt-get clean

RUN echo && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/415/gwenhywfar-5.9.0.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/499/aqbanking-6.5.4.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  cd /usr/src/gwenhywfar* && \
  make -fMakefile.cvs && \
  ./configure --prefix=/ --exec-prefix=/usr --with-guis="" && \
  make -j $( nproc ) && \
  make install && \
  cd /usr/src/aqbanking* && \
  make -fMakefile.cvs -j $( nproc ) && \
  ./configure --prefix=/ --exec-prefix=/usr --with-xmlmerge=/usr/bin/xmlmerge && \
  make typedefs && \
  make types && \
  make -j $( nproc ) && \
  make install && \
  rm -R /usr/src/*


COPY gencsv.sh /usr/local/bin/
COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 aqbanking && \
  chmod +x /usr/local/bin/ -R

