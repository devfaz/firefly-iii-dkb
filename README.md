# firefly-iii-dkb 

* csv-convert.py: konvertiert eingehende CSV-Dateien (z.B. aus aqbanking oder dem Webinterface der DKB) in ein Format, welches erfahrungsgemäß die wenigsten Probleme beim Import in den CSV-Importer macht.

* Dockerfile: baut die neuste Version von aqbanking als Container-Image

* gencsv.sh: erzeugt eine CSV mittels aqbanking

* start-giro.sh: baut das obige Image (falls nötig), erzeugt mittels aqbanking ein CSV und konvertiert es passend für den CSV-Importer.
Erwartet eine "env"-Datei basierend auf der "env.template". Diese Datei einfach in `$HOME/.aqbanking` ablegen.

---

aqbanking DKB Setup:

* das obige aqbanking-Image starten

```
podman run --rm -it -v $HOME/.aqbanking/:/root/.aqbanking/ aqbanking /bin/bash
```

und anschließend im Container die Einrichtung durchführen:

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

Erläuterungen der Befehle auf der aqbanking Website.
