<h1 align="center">
    <br>
        defi-masternode-secure-installation
    <br>
</h1>

<div align="center">
    
[:gb::us: Translation](https://github.com/vmerz/defi-masternode-secure-installation/README.EN.md) 

</div>

<h4 align="center">
    Anleitung & Skript zur sicheren Installation einer DefiChain Masternode.
    Wünsche und Verbesserungsvorschläge sind willkommen.
</h4>

<p align="center">
  <a href="#Betriebssystemempfehlung">Betriebssystemempfehlung</a> •
  <a href="#Installation kompakt">Installation kompakt</a> •
  <a href="#Installation ausführlich">Installation ausführlich</a> •
  <a href="#Installationsskript">Installationsskript</a> •
  <a href="#Support">Support</a> •
  <a href="#license">License</a>
</p>

<div align="center">
    
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
    
</div>

<br>

## Schützt eure Masternode!

Die meisten Installationsanleitungen für Masternodes erwähnen das Thema Sicherheit nur am Rande.
Ihr seid im Begriff, einen Server offen ins Internet zu stellen und auch noch einiges an Coins auf dessen Wallet zu übertragen. Wir sollten uns also unbedingt mit dem Thema Serversicherheit auseinandersetzen.

## Betriebssystemempfehlung

Debian buster

## Installation kompakt

Kurz und knapp alles zur manuellen Installation

```bash
# Wechseln zu root, wenn ihr nicht schon root seid
su -
# Installation der benötigten Packages
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc

# Wir würfeln uns einen neuen SSH-Port
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))

# SSH-Port ändern
nano -w /etc/ssh/sshd_config

# Benötigte Ports in der Firewall freigeben
ufw allow 50695/tcp
ufw allow 8555/tcp

# Benutzer zur Ausführung der Masternode anlegen
adduser defichain

# SSH neustarten
systemctl restart ssh

# Firewall aktivieren
ufw enable

# zu normalem Benutzer wechseln 
su defichain

#Snapshot laden
mkdir snapshot
cd snapshot 
wget https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip snapshot……
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ./* ~/.defi/

wget https://github.com/DeFiCh/ain/releases/download/v1.8.1/defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz

tar -xvzf defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz
mkdir /home/defichain/.defi
cp ./defichain-1.8.1/bin/* /home/defichain/.defi
~/.defi/defid -daemon
~/.defi/defi-cli getblockcount 

```


## Installation ausführlich

Hier werden alle Installationsschritte einzeln beschrieben. 
Zu viel Infos? Dann einfach direkt zum <a href="#Installationsskript">Installationsskript</a>.
<br>

### Systemupdate und Paketinstallation

### SSH konfigurieren

### Firewall konfigurieren

### Benutzeranlage

### Masternode installieren



Folgende Themen werden behandelt und später auch über das Installationsskript abgedeckt

* Ufw als einfach zu administrierende Firewall
* Fail2ban - 
* Kein ssh-Zugang für root
* Kein sudo
* SSH auf einen anderen Port verschieben.




## Installationsskript


## Support

DFI: dYVqg7U4Ubio8uLjsCBQzZseLXFJivr2h1

## Lizenz 

 GNU GPLv3 