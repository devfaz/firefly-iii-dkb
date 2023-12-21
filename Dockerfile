FROM debian@sha256:bac353db4cc04bc672b14029964e686cd7bad56fe34b51f432c1a1304b9928da
LABEL org.opencontainers.image.source = "https://github.com/devfaz/firefly-iii-dkb"

RUN apt-get -qy update && \
  apt-get -qy install git-core build-essential  libtool libgcrypt-dev gnutls-dev pkg-config libxmlsec1-dev libz-dev wget gettext python3-pip && \
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

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt --break-system-packages && \
  rm /requirements.txt

COPY gencsv.sh csv-convert.py /usr/local/bin/
COPY dkb-csv-export-profile.conf /opt/

RUN useradd --uid 1000 aqbanking && \
  chmod +x /usr/local/bin/ -R

