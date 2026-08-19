FROM debian:13@sha256:34cd9e9fd437c0a095ec39cb2e73422c9f30821b0d0848ed74fd0d43bae4d958
LABEL org.opencontainers.image.source="https://github.com/devfaz/firefly-iii-dkb"

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext python3-pip curl ca-certificates webhook && \
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
    bin/autoimport.sh \
    bin/entrypoint.sh \
    bin/balances.py \
    bin/process.sh \
    /usr/local/bin/
COPY webhook/hooks.yaml /etc/webhook/hooks.yaml
COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 --create-home aqbanking && \
  chmod +x /usr/local/bin/ -R

USER 1000
EXPOSE 9000
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
