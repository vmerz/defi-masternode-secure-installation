<h1 align="center">
    <br>
        defi-masternode-secure-installation
    <br>
</h1>

<div align="center">
    
[:de: Übersetzung](https://github.com/vmerz/defi-masternode-secure-installation/blob/main/README.md) 

</div>

<h4 align="center">
    Instructions & script for the safe installation of a DefiChain master node.<br>
</h4>
<p align="center">
    Wishes and suggestions for improvement are welcome.
</p>

<p align="center">
  <a href="#OperatingSystemRecommendation">Operating System Recommendation</a> •
  <a href="#Installation-compact">Installation compact</a> •
  <a href="#Installation-in-detail">Installation in detail</a> •
  <a href="#Installation-script">Installation script</a> •
  <a href="#Support">Support</a> •
  <a href="#License">License</a>
</p>

<div align="center">

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

## Protect your masternode!

Most installation instructions for master nodes only mention the topic of security in passing.
You are about to put a server openly on the Internet and also transfer some coins to its wallet. So we should definitely deal with the topic of server security.

## Operating system recommendation

I recommend the current <a href="#https://www.debian.org/CD/netinst/index.de.html">Debian operating system in the minimal version</a>. Debian is focused on stability and security. It does not have all packages on board in the latest version, of course, but that has a good reason. New packages and versions are not included in the release until they are deemed stable and secure enough.

Also, in my installations, a distribution upgrade with Debian has always worked flawlessly, with Ubuntu, for example, never completely error-free or not at all.

## Installation compact

Short and sweet everything about the manual installation

```bash
# Switch to root & install the required packages
su -
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc unzip wget

# We dice ourselves a new SSH port and change the config
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
sed -i "/^Port/s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "ATTENTION: use the port $SSH_PORT at the next LOGIN via SSH. Ex: ssh defichain@yourIP -p $SSH_PORT."
# NOTE THE NEW SSH PORT!

# create user to run the masternode
adduser defichain
# enter passwords and data for user

# Allow required ports in the firewall
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp

# Restart SSH
systemctl restart ssh

# Enable firewall
ufw enable

# switch to normal user 
su defichain

# install the masternode
wget -P ~/ https://github.com/DeFiCh/ain/releases/download/v1.8.2/defichain-1.8.2-x86_64-pc-linux-gnu.tar.gz
tar -xvzf ~/defichain-1.8.2-x86_64-pc-linux-gnu.tar.gz -C ~/
mkdir ~/.defi
cp ~/defichain-1.8.2/bin/* ~/.defi

# Download snapshot to make the node sync faster
mkdir -p ~/snapshot
wget -P ~/snapshot https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip ~/snapshot/*.zip -d ~/snapshot/
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ~/snapshot/* ~/.defi/

# Start masternode daemon
~/.defi/bin/defid -daemon
# Query current block count
~/.defi/bin/defi-cli getblockcount
```

Done! Now we continue with the <a href="https://defichain.com/learn/run-a-masternode/#step-3---setting-up-crontab-to-keep-our-node-running-in-the-background">official tutorial from Step 3</a>
<br>Or in the wiki with <a href="https://defichain-wiki.com/wiki/Masternode_installation_extended#Configure_automatic_start">Configure automatic start</a>.

You want to know what you just did? Then just read on.

## Installation in detail

Here all installation steps are described individually.
Too much info? Then just go directly to the <a href="#installation-script">installation script</a> or back to the
<a href="#installation-compact">compact manual</a>

:soon:

## Installation script

:soon:

## Support

:coffee: or :beer: for the writer ;)

DFI: dYVqg7U4Ubio8uLjsCBQzZseLXFJivr2h1

## Licence 

 GNU GPLv3 
