<h1 align="center">
    <br>
        defi-masternode-secure-installation
    <br>
</h1>

<div align="center">

[:gb::us: Translation](https://github.com/vmerz/defi-masternode-secure-installation/blob/main/README.EN.md)

</div>

<h4 align="center">
    Anleitung & Skript zur sicheren Installation einer DefiChain Masternode.<br>
</h4>
<p align="center">
    Wünsche und Verbesserungsvorschläge sind willkommen.
</p>

<p align="center">
  <a href="#Betriebssystemempfehlung">Betriebssystemempfehlung</a> •
  <a href="#Installationsskript">Installationsskript</a> •
  <a href="#installation-kompakt">Installation kompakt</a> •
  <a href="#installation-ausführlich">Installation ausführlich</a> •
  <a href="#Support">Support</a> •
  <a href="#Lizenz">Lizenz</a>
</p>

<div align="center">

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

## Schützt eure Masternode!

Die meisten Installationsanleitungen für Masternodes erwähnen das Thema Sicherheit nur am Rande.
Ihr seid im Begriff, einen Server offen ins Internet zu stellen und auch noch einiges an Coins auf dessen Wallet zu übertragen. Wir sollten uns also unbedingt mit dem Thema Serversicherheit auseinandersetzen.

## Betriebssystemempfehlung

Ich empfehle das aktuelle <a href="#https://www.debian.org/CD/netinst/index.de.html">Debian-Betriebssystem in der Minimalversion</a>. Debian ist auf Stabilität und Sicherheit ausgerichtet. Es hat natürlich nicht alle Pakete in der neuesten Version an Bord, das hat aber auch einen guten Grund. Neue Pakete und Versionen werden erst in das Release übernommen, wenn sie als stabil und sicher genug erachtet wurden.

Auch hat bei meinen Installationen ein Distributionsupgrade mit Debian immer einwandfrei funktioniert, mit Ubuntu z.B. noch nie komplett fehlerfrei oder überhaupt nicht.

## Installationsskript

Automatisches Installationsskript. Masternode installieren ohne viel Leserei.

```bash
su -
apt install wget && wget https://github.com/vmerz/defi-masternode-secure-installation/raw/main/installDefiMasternode.sh
chmod +x installDefiMasternode.sh
bash installDefiMasternode.sh
```

Geschafft! Jetzt geht es weiter mit der <a href="https://defichain.com/learn/run-a-masternode/#step-3---setting-up-crontab-to-keep-our-node-running-in-the-background">offiziellen Anleitung ab Step 3</a>
<br>ODER im Wiki mit <a href="https://defichain-wiki.com/wiki/Masternode_installation_extended_de#Automatischen_Start_konfigurieren">Automatischen Start konfigurieren</a>

Ihr wollt es genauer wissen? Dann einfach weiterlesen.

## Installation kompakt

Kurz und knapp manuell installieren

```bash
# Wechseln zu root & Installation der benötigten Pakete
su -
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc unzip wget

# SSH-Port würfeln und in der Konfigurationsdatei ändern
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
sed -i "/^Port/s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "ACHTUNG: beim nächsten LOGIN per SSH den Port $SSH_PORT nutzen. Bsp.: ssh defichain@yourIP -p $SSH_PORT."
# NOTIERT EUCH DEN NEUEN SSH-PORT!

# Benutzer zur Ausführung der Masternode anlegen
adduser defichain
# Passwörter und Daten zu User eingeben

# Benötigte Ports in der Firewall freigeben
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp

# SSH neustarten
systemctl restart ssh

# Firewall aktivieren
ufw enable

# zu normalem Benutzer wechseln 
su defichain

# Masternode installieren
wget -P ~/ https://github.com/DeFiCh/ain/releases/download/v1.8.4/defichain-1.8.4-x86_64-pc-linux-gnu.tar.gz
tar -xvzf ~/defichain-1.8.4-x86_64-pc-linux-gnu.tar.gz -C ~/
mkdir ~/.defi
cp ~/defichain-1.8.4/bin/* ~/.defi

# Snapshot herunterladen, damit die Node schneller synchronisiert
mkdir -p ~/snapshot
wget -P ~/snapshot https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip ~/snapshot/*.zip -d ~/snapshot/
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ~/snapshot/* ~/.defi/

# Masternode-Daemon starten
~/.defi/bin/defid -daemon
# Aktuellen Blockcount abfragen
~/.defi/bin/defi-cli getblockcount 
```

Geschafft! Jetzt geht es weiter mit der <a href="https://defichain.com/learn/run-a-masternode/#step-3---setting-up-crontab-to-keep-our-node-running-in-the-background">offiziellen Anleitung ab Step 3</a>
<br>ODER im Wiki mit <a href="https://defichain-wiki.com/wiki/Masternode_installation_extended_de#Automatischen_Start_konfigurieren">Automatischen Start konfigurieren</a>

Ihr wollt wissen, was ihr gerade getan habt? Dann lest einfach weiter.

## Installation ausführlich

Hier werden alle Installationsschritte einzeln beschrieben.
Zu viel Infos? Dann einfach direkt zum <a href="#Installationsskript">Installationsskript</a> oder zurück zur
<a href="#installation-kompakt">Kompaktanleitung</a>

### Systemupdate und Paketinstallation

Zuerst wird das System aktualisiert und die notwendigen Pakete installiert. Wenn ihr nicht mehrere Administratoren auf dem System habt, schlagt euch `sudo` aus dem Kopf.
Hier wird komplett auf `sudo` verzichtet, ich möchte hier aber auch keine `sudo`-Debatte starten.

Wir wechseln zu root und Installieren:

```bash
su -
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc unzip wget
```

#### Installierte Pakete

##### ufw

Ufw ist eine einfach zu administrierende Firewall.

##### nano

Nano benötigen wir, um Dateien zu bearbeiten. Im Vergleich zu vi ist er für Einsteiger intuitiver zu bedienen.

##### psmisc

Enthält u.a. den Befehl killall, der in der offiziellen Doku verwendet wird.

###### htop

Ein kleines Tool zur Darstellung und Verwaltung der laufenden Prozesse.

###### fail2ban

Blockiert IP-Adressen nach fehlgeschlagenen Login-Versuchen.

###### wget

Ermöglicht den Download von Dateien via HTTP/HTTPS & FTP.

### SSH konfigurieren

Wir generieren uns einen neuen Port für den SSH-Zugang. Das ist zwar keine richtige Sicherheitsmaßnahme, allerdings werden Server meist nur auf Standardports gescanned, um sie auf Sicherheitslücken zu untersuchen (Ports 443, 80, 81, usw...). Werft einfach mal einen Blick mit `cat /var/log/ufw.log` ins Firewall-Log, nachdem euer Server eine Weile läuft. 
Außerdem wird der Zugang für `root` per SSH verboten.

```bash
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
sed -i "/^Port/s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "ACHTUNG: beim nächsten LOGIN per SSH den Port $SSH_PORT nutzen. Bsp.: ssh defichain@yourIP -p $SSH_PORT"
```

**Notiert euch den neuen SSH-Port!**
Ansonsten habt ihr euch nach dem Logout selbst vom System ausgeschlossen.

### Benutzeranlage

Benutzer zur Ausführung der Masternode anlegen.

```bash
adduser defichain
```

### Firewall konfigurieren

Nur die notwendigen Ports werden in der Firewall freigegeben. Wir schalten den neuen SSH-Port und den Port für die Kommunikation der Masternode frei. Nachdem die Ports offen sind, wird der SSH-Dienst neu gestartet.

```bash
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp
systemctl restart ssh
```

Um die neue Konfiguration zu testen, meldet ihr euch am Besten in einem zweiten Terminal mit dem neuen Port und dem User `defichain` an, da der Login für root jetzt verboten ist `ssh defichain@EureServerIP -p SSH_PORT`.

### Masternode installieren

Aktuelle Maternode herunterladen, entpacken und in das richtige Verzeichnis verschieben.

```bash
wget -P ~/ https://github.com/DeFiCh/ain/releases/download/v1.8.4/defichain-1.8.4-x86_64-pc-linux-gnu.tar.gz
tar -xvzf ~/defichain-1.8.4-x86_64-pc-linux-gnu.tar.gz -C ~/
mkdir ~/.defi
cp ~/defichain-1.8.4/bin/* ~/.defi
```

Bevor die Node gestartet wird, wird der Snapshot heruntergeladen, damit die Node schneller synchronisiert.

```bash
mkdir -p ~/snapshot
wget -P ~/snapshot https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip ~/snapshot/*.zip -d ~/snapshot/
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ~/snapshot/* ~/.defi/
```

Den Masternode Dienst starten

```bash
# Masternode-Daemon starten
~/.defi/defid -daemon
# Aktuellen Blockcount abfragen
~/.defi/defi-cli getblockcount
```
Geschafft! Jetzt geht es weiter mit der <a href="https://defichain.com/learn/run-a-masternode/#step-3---setting-up-crontab-to-keep-our-node-running-in-the-background">offiziellen Anleitung ab Step 3</a>
<br>ODER im Wiki mit <a href="https://defichain-wiki.com/wiki/Masternode_installation_extended_de#Automatischen_Start_konfigurieren">Automatischen Start konfigurieren</a>

## Support

:coffee: oder :beer: für den Schreiberling ;)

DFI: dYVqg7U4Ubio8uLjsCBQzZseLXFJivr2h1

## Lizenz

GNU GPLv3
