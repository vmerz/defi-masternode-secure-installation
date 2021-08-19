<h1 align="center">
    <br>
        defi-masternode-secure-installation
    <br>
</h1>

<div align="center">
    
[:gb::us: Translation](https://github.com/vmerz/defi-masternode-secure-installation/README.EN.md) 

</div>

<h4 align="center">
    Anleitung & Skript zur sicheren Installation einer DefiChain Masternode.<br>
</h4>
<p align="center">
    Wünsche und Verbesserungsvorschläge sind willkommen.
</p>

<p align="center">
  <a href="#Betriebssystemempfehlung">Betriebssystemempfehlung</a> •
  <a href="#installation-compact">Installation kompakt</a> •
  <a href="#installation-detailed">Installation ausführlich</a> •
  <a href="#Installationsskript">Installationsskript</a> •
  <a href="#Support">Support</a> •
  <a href="#license">Lizenz</a>
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

## Installation kompakt {#installation-compact}

Kurz und knapp alles zur manuellen Installation

```bash
# Wechseln zu root & Installation der benötigten Pakete
su -
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc

# SSH-Port würfeln und in der Konfigurationsdatei ändern
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
sed -i "/^Port/s/50695/${SSH_PORT}/g" /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "ACHTUNG: beim nächsten LOGIN per SSH den Port $SSH_PORT nutzen. Bsp.: ssh defichain@yourIP -p $SSH_PORT."

# Benutzer zur Ausführung der Masternode anlegen
adduser defichain

# Benötigte Ports in der Firewall freigeben
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp

# SSH neustarten
systemctl restart ssh

# Firewall aktivieren
ufw enable

# zu normalem Benutzer wechseln 
su defichain

#Snapshot laden
mkdir ~/snapshot
wget -P ~/snapshot https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip ~/snapshot/*.zip
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ~/snapshot/* ~/.defi/

wget -P ~/ https://github.com/DeFiCh/ain/releases/download/v1.8.1/defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz

tar -xvzf ~/defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz
mkdir /home/defichain/.defi
cp ./defichain-1.8.1/bin/* /home/defichain/.defi
~/.defi/defid -daemon
~/.defi/defi-cli getblockcount 
```

## Installation ausführlich {#installation-detailed}

Hier werden alle Installationsschritte einzeln beschrieben. 
Zu viel Infos? Dann einfach direkt zum <a href="#Installationsskript">Installationsskript</a> oder zurück zur
<a href="#installation-compact">Kompaktanleitung</a> 
<br>

### Systemupdate und Paketinstallation

Zuerst wird das System aktualisiert und die notwendigen Pakete installiert. Wenn ihr nicht mehrere Administratoren auf dem System habt, schlagt euch `sudo` aus dem Kopf. Warum? .....
Deshalb wird hier komplett auf den Einsatz von `sudo` verzichtet, ich rate im Normalfall von dessen Installation ab.

Wir wechseln zu root und Installieren:

```bash
su -
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc
```

#### Installierte Pakete

##### ufw

Ufw ist eine einfach zu administrierende Firewall und für unsere Zwecke vollkommend ausreichend.

##### nano

Nano benötigen wir, um Dateien zu bearbeiten. Im Vergleich zu vi ist er für Einsteiger intuitiver zu bedienen.

##### psmisc

Enthält u.a. den Befehl killall, der in der offiziellen Doku verwendet wird.

###### htop

Ein kleines Tool zur schickeren Darstellung und Verwaltung der laufenden Prozesse als das Standardtool top.

###### fail2ban

Blockiert IP-Adressen nach mehreren fehlgeschlagenen Login-Versuchen.

### SSH konfigurieren

Wir generieren uns einen neuen Port für den SSH-Zugang. Das ist zwar noch keine "richtige" Sicherheitsmaßnahme, allerdings werden meist viele Server auf Standardports gescanned, um sie auf Sicherheitslecks zu untersuchen. Dies sind z.B. 443, 80, 81, etc.... Werft einfach mal einen Blick ins Firewall-Log, nachdem euer Server eine Weile läuft. [`cat /var/log/ufw.log`]

```bash
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
sed -i "/^Port/s/50695/${SSH_PORT}/g" /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "ACHTUNG: beim nächsten LOGIN per SSH den Port $SSH_PORT nutzen. Bsp.: ssh defichain@yourIP -p $SSH_PORT"
```

### Benutzeranlage

Benutzer zur Ausführung der Masternode anlegen.

```bash
adduser defichain
```

### Firewall konfigurieren

Nur die wirklich notwendigen Ports sollten in der Firewall freigegeben werden. Wir schalten den neuen SSH-Port frei und den Port für die Kommunikation der Masternode. Nachdem die Ports offen sind, starten wir den SSH-Dienst neu.

```bash
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp
systemctl restart ssh
```
Um die neue Konfiguration zu testen, meldet ihr euch am Besten in einem zweiten Terminal mit dem neuen Port und dem  
User `defichain` an, da der Login für root jetzt verboten ist. [`ssh defichain@EureServerIP -p ]

### Masternode installieren

Folgende Themen werden behandelt und später auch über das Installationsskript abgedeckt

* Ufw als einfach zu administrierende Firewall
* Fail2ban - 
* Kein ssh-Zugang für root
* Kein sudo
* SSH auf einen anderen Port verschieben.

## Installationsskript

TBD

## Support

DFI: dYVqg7U4Ubio8uLjsCBQzZseLXFJivr2h1

## Lizenz 

 GNU GPLv3 