# firefly-iii-dkb 

# SETUP

## Vorraussetzung

* Docker / Podman / containerd (nerdctl) / ...

## Config-Dateien

Es wird eine "env"-Datei basierend auf der "env.template" benötigt.

Einfach die env.template nach `$HOME/.aqbanking` kopieren und an ihre Zugangsdaten anpassen
```
mkdir -pv $HOME/.aqbanking
cp env.template $HOME/.aqbanking/env
```

## aqbanking DKB Setup:

* das aqbanking-Image starten

```
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ ghcr.io/devfaz/firefly-iii-dkb/aqbanking:latest /bin/bash
```

* anschließend im Container die Einrichtung durchführen:

```
LOGIN="<DKB-Webinterface-Login>"
NAME="<Vor und Nachname, wie er im Webinterface hinterlegt ist>"
aqhbci-tool4 adduser -t pintan --context=1 -b 12030000 -u ${LOGIN} -s "https://banking-dkb.s-fints-pt-dkb.de/fints30" -N ${NAME} --hbciversion=300
aqhbci-tool4 getbankinfo -u 1
aqhbci-tool4 getsysid -u 1
aqhbci-tool4 listitanmodes -u 1
aqhbci-tool4 setitanmode -u 1 -m 6921
aqhbci-tool4 getaccounts -u 1
aqhbci-tool4 listaccounts -v

# für jeden gewünschten Account dann:
aqhbci-tool4 getaccsepa -a <ACCOUNT_ID>
```
*weitere Erläuterungen der Befehle auf der aqbanking Website*

* den Container wieder verlassen
```
exit
```

## Abruf starten

```
./start-dkb.sh
```

Alle folgenden Abrufe werden nur noch die seit dem letzten Abruf aufgelaufenen Buchungen abrufen.
Sämtliche Status-Dateien liegen in $HOME/.aqbanking/ und können - bei Bedarf - editiert werden.

# Dateien

**csv-convert.py**

konvertiert eingehende CSV-Dateien (z.B. aus aqbanking oder dem Webinterface der DKB) in ein Format, welches erfahrungsgemäß die wenigsten Probleme beim Import in den CSV-Importer macht.

**Dockerfile**

erzeugt ein Container-Image welches aqbanking enthält

**gencsv.sh**

erzeugt eine CSV mittels aqbanking

**start-dkb.sh**

erzeugt mittels aqbanking (siehe gencsv.sh) ein CSV und konvertiert es passend für den CSV-Importer (csv-convert.py)

**start-barc.sh**

sucht eine Umsätze.xlsx in $HOME/Downloads/ und erzeugt daraus eine CSB für firefly-iii-importer.
Die Umsätze.xlsx kann einfach aus der WebGUI der Barclay heruntergeladen werden.

---
