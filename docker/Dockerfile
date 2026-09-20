FROM debian:13@sha256:9cc080028c43b27d2074d63a5f9caf7166d731494965616c1a6d2827a004585c
LABEL org.opencontainers.image.source="https://github.com/devfaz/firefly-iii-dkb"

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext python3-pip curl ca-certificates && \
  apt-get clean

RUN echo && \
  wget "https://aquamaniac.de/rdm/attachments/download/630/gwenhywfar-5.14.1.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
  wget "https://aquamaniac.de/rdm/attachments/download/646/aqbanking-6.8.4.tar.gz" -O- | tar -xzvf- -C /usr/src/ && \
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

COPY bin/gencsv.sh \
    bin/csv-convert.py \
    bin/entrypoint.sh \
    bin/balances.py \
    bin/process.sh \
    bin/webhook_server.py \
    /usr/local/bin/
COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 --create-home aqbanking && \
  chmod +x /usr/local/bin/ -R

USER 1000
EXPOSE 9000
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
