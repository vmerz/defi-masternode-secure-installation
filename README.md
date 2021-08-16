<h1 align="centre">
    <br>
        defi-masternode-secure-installation
    <br>
</h1>

<h4 align="centre">
    Instructions & script for the secure installation of a DefiChain masternode.
    Wishes and suggestions for improvement are welcome.
</h4>

<p align="centre">
  <a href="#OperatingSystemRecommendation">Operating System Recommendation</a> -.
  <a href="#Installation compact">Installation compact</a> -
  <a href="#Installation detailed">Installation detailed</a> -
  <a href="#Installation script">Installation script</a> -
  <a href="#Support">Support</a> -
  <a href="#license">license</a>
</p>

<br>

## Protect your masternode!

Most installation guides for masternodes only mention the topic of security in passing.
You are about to put a server openly on the internet and also transfer some coins to its wallet. So we should definitely deal with the topic of server security.

## Operating system recommendation

Debian buster

## Installation compact

Short and sweet everything about the manual installation

``bash
# change to root if you are not already root
su -
# install the required packages
apt -y update && apt -y upgrade
apt -y install ufw nano htop fail2ban psmisc

# We dice ourselves a new SSH port
SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))

# Change SSH port
nano -w /etc/ssh/sshd_config

# Allow required ports in the firewall
ufw allow 50695/tcp
ufw allow 8555/tcp

# Create user to run the masternode
adduser defichain

# Restart SSH
systemctl restart ssh

# Enable firewall
ufw enable

# switch to normal user 
su defichain

#load snapshot
mkdir snapshot
cd snapshot 
wget https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip
unzip snapshot......
rm -Rf ~/.defi/chainstate ~/.defi/enhancedcs ~/.defi/blocks
mv ./* ~/.defi/

wget https://github.com/DeFiCh/ain/releases/download/v1.8.1/defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz

tar -xvzf defichain-1.8.1-x86_64-pc-linux-gnu.tar.gz
mkdir /home/defichain/.defi
cp ./defichain-1.8.1/bin/* /home/defichain/.defi
~/.defi/defid -daemon
~/.defi/defi-cli getblockcount 

```


## Installation in detail

Here all installation steps are described individually. 
Too much info? Then just go directly to the <a href="#installation script">installation script</a>.
<br>

### System update and package installation

### Configure SSH

### Configure firewall

### User installation

### Installing the masternode



The following topics are covered and will also be covered later on via the installation script

* Ufw as an easy-to-administer firewall
* Fail2ban - 
* No ssh access for root
* No sudo
* Moving SSH to another port.




## Installation script


## Support

DFI: dYVqg7U4Ubio8uLjsCBQzZseLXFJivr2h1

## Licence 

 GNU GPLv3 

Translated with www.DeepL.com/Translator (free version)