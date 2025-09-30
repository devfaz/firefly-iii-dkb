FROM debian:trixie@sha256:fd8f5a1df07b5195613e4b9a0b6a947d3772a151b81975db27d47f093f60c6e6
LABEL org.opencontainers.image.source = "https://github.com/devfaz/firefly-iii-dkb"

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext python3-pip curl ca-certificates && \
  apt-get clean

RUN echo && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/529/gwenhywfar-5.12.0.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  wget "https://www.aquamaniac.de/rdm/attachments/download/531/aqbanking-6.6.0.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
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

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt --break-system-packages && \
  rm /requirements.txt

COPY gencsv.sh csv-convert.py /usr/local/bin/
COPY start-dkb.sh /usr/local/bin
COPY autoimport.sh /usr/local/bin
COPY entrypoint.sh /usr/local/bin
COPY balances.py /usr/local/bin

COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 --create-home aqbanking && \
  chmod +x /usr/local/bin/ -R

USER 1000
ENTRYPOINT /usr/local/bin/entrypoint.sh
