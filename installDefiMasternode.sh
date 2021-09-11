#!/usr/bin/env bash

#_exit definitions_____________________________________________________________
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

trap cleanup 0 SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM EXIT

#_variables____________________________________________________________________

#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
#__base="$(basename ${__file} .sh)"
#__root="$(cd "$(dirname "${__dir}")" && pwd)"

USERNAME="defichain"

#_constants____________________________________________________________________

EXIT_CODE_NO_ROOT=3
EXIT_CODE_INSTALLATION_ABORTED=4


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

INFO=${INFO:-"1"}
DEBUG=${DEBUG:-"0"}
ERROR=${ERROR:-"1"}
WARNING=${WARNING:-"1"}
SUCCESS=${SUCCESS:-"1"}

#_DEFI constants_______________________________________________________________

MASTERNODE_ARCHIVE="defichain-1.8.4-x86_64-pc-linux-gnu.tar.gz"
MASTERNODE_DOWNLOAD_URL="https://github.com/DeFiCh/ain/releases/download/v1.8.4/$MASTERNODE_ARCHIVE"
MASTERNODE_RELEASE_FOLDER="defichain-1.8.4"

SNAPSHOT_DOWNLOAD_URL="https://defi-snapshots-europe.s3.eu-central-1.amazonaws.com/snapshot-mainnet-1052243.zip"

#_functions____________________________________________________________________

function cleanup() {

    if [ $? -ne $EXIT_CODE_NO_ROOT ]
        then
            __msg_info "Start cleanup"

            # -f "/tmp/${lock_file}.lock"
            rm -f /tmp/$MASTERNODE_ARCHIVE
            rm -r -f /tmp/$MASTERNODE_RELEASE_FOLDER

            __msg_success "Cleanup finished"
    fi
   
}

# Reads a value from the keyboard and returns it
# Call with defaultvalue: variable=$(promptValue "text of the query" $defaultvalue)
# Call without default value: variable=$(promptValue "Text of the query")
function promptValue() {
 if [ -z ${2+x} ]; 
 	then 
 		read -r -e -p "$1"": " val;
 	else 
		read -r -e -p "$1 [$2]:" val
		val=${val:-$2}
 	fi
 echo "$val"
}

function __msg_error() {
    [[ "${ERROR}" == "1" ]] && echo -e "${RED}[ERROR]:   $*" && echo -ne "${NC}"
}

function __msg_warning() {
    [[ "${WARNING}" == "1" ]] && echo -e "${YELLOW}[WARNING]: $*" && echo -ne "${NC}"
}

function __msg_success() {
    [[ "${SUCCESS}" == "1" ]] && echo -e "${GREEN}[SUCCESS]: $*" && echo -ne "${NC}"
}

function __msg_info() {
    [[ "${INFO}" == "1" ]] && echo -e "${NC}[INFO]:    $*" && echo -ne "${NC}"
}

function askInstallDefiMasternode(){

	if [ -d "$MASTERNODE_TARGET_FOLDER" ]; 
		then #Masternode-folder already exists?
		echo ''
			while true; do
			case $(promptValue "Masternode-folder already exists, continue installation and overwrite?(y/n)" "y") in 
			  y|Y )
			          rm -r "${MASTERNODE_TARGET_FOLDER:?}"
                installDefiMasternode
				
			    break ;;
			  n|N )
					__msg_warning "Masternode installation skipped by user"

                    exit ${EXIT_CODE_INSTALLATION_ABORTED}
					break ;;
			  * ) 	__msg_warning "Invalid input"
					echo -e "${NC}";;
			esac
	    done
	else
		installDefiMasternode
	fi
}

function installDefiMasternode(){

    __msg_info "Install Masternode"

    wget -P /tmp -q --show-progress $MASTERNODE_DOWNLOAD_URL
    tar -xzf /tmp/$MASTERNODE_ARCHIVE -C /tmp/
    mkdir -p "$MASTERNODE_TARGET_FOLDER"
    cp -R /tmp/$MASTERNODE_RELEASE_FOLDER/* "$MASTERNODE_TARGET_FOLDER"

    chown -R $USERNAME: "$MASTERNODE_TARGET_FOLDER"

    __msg_success "Masternode installed"
}

function downloadDefiSnapshot(){

    __msg_info "Install snapshot"

    mkdir -p /tmp/snapshot
    wget -P /tmp/snapshot -q --show-progress $SNAPSHOT_DOWNLOAD_URL
    unzip -q /tmp/snapshot/*.zip -d /tmp/snapshot/
    rm -Rf "${MASTERNODE_TARGET_FOLDER:?}/"chainstate 
    rm -Rf "${MASTERNODE_TARGET_FOLDER:?}/"enhancedcs
    rm -Rf "${MASTERNODE_TARGET_FOLDER:?}/"blocks

    mv /tmp/snapshot/* "$MASTERNODE_TARGET_FOLDER"

    chown -R $USERNAME: "$MASTERNODE_TARGET_FOLDER"

    __msg_success "Snapshot installed"
}

function changesshPort(){

    # We dice ourselves a new SSH port and change the config
    SSH_PORT=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
    sed -i '/^#Port/s/#Port/Port/' /etc/ssh/sshd_config
    sed -i "/^Port/s/22/${SSH_PORT}/g" /etc/ssh/sshd_config
    sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
    echo "ATTENTION: use the port $SSH_PORT at the next LOGIN via SSH. Ex: ssh $USERNAME@yourIP -p $SSH_PORT."
}

#_start________________________________________________________________________

if [ "$EUID" -ne 0 ]
  then __msg_error "Please execute as root"
  exit ${EXIT_CODE_NO_ROOT}
fi

clear

USERNAME=$(promptValue "Please select the username that should run the masternode process. Enter for default name" $USERNAME)
MASTERNODE_TARGET_FOLDER="/home/$USERNAME/.defi"

# create user to run the masternode
id -u "$USERNAME" &>/dev/null || adduser --gecos "" "$USERNAME"

__msg_info "System is being updated"
DEBIAN_FRONTEND=noninteractive apt-get update -qq < /dev/null > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get upgrade -qq < /dev/null > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -qq ufw nano htop fail2ban psmisc unzip wget < /dev/null > /dev/null

askInstallDefiMasternode
downloadDefiSnapshot

changesshPort

# enter passwords and data for user

# Allow required ports in the firewall
ufw allow $SSH_PORT/tcp
ufw allow 8555/tcp

# Restart SSH
systemctl restart ssh

# Enable firewall
ufw enable

# Start defi daemon
COMMAND="${MASTERNODE_TARGET_FOLDER:?}/"bin/defid
runuser -u $USERNAME -- $COMMAND -daemon

__msg_info "Daemon started, please switch to user $USERNAME"