#!/usr/bin/env bash

#_exit definitions_____________________________________________________________
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

trap cleanup 0 SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM EXIT

#_variables____________________________________________________________________

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" 

#_constants____________________________________________________________________
SUCCESS=0
FILE_NOT_FOUND=240
INSTALLATION_ABORTED=300
NO_ROOT=1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

INFO=${INFO:-"1"}
DEBUG=${DEBUG:-"0"}
ERROR=${ERROR:-"1"}
WARNING=${WARNING:-"1"}

MASTERNODE_ARCHIVE="defichain-1.8.2-x86_64-pc-linux-gnu.tar.gz"
MASTERNODE_DOWNLOAD_URL="https://github.com/DeFiCh/ain/releases/download/v1.8.2/$MASTERNODE_ARCHIVE"
MASTERNODE_RELEASE_FOLDER="defichain-1.8.2"
MASTERNODE_TARGET_FOLDER="$HOME/.defi"

#_functions____________________________________________________________________

function cleanup() {
  # for eg. rm -f "/tmp/${lock_file}.lock"
  rm -f /tmp/$MASTERNODE_ARCHIVE
  rm -r -f /tmp/$MASTERNODE_RELEASE_FOLDER
}

# Liest einen Wert von der Tastatur ein und gibt diesen zurück
# Aufruf mit Defaultvalue: variable=$(promptValue "Text der Abfrage" $defaultwert)
# Aufruf ohne Defaultvalue: variable=$(promptValue "Text der Abfrage")
function promptValue() {
 if [ -z ${2+x} ]; 
 	then 
 		read -r -e -p "$1"": " val;
 	else 
		read -r -e -p "$1 [$2]:" val
		val=${val:-$2}
 	fi
 echo $val
}

function __msg_error() {
    [[ "${ERROR}" == "1" ]] && echo -e "${RED}[ERROR]: $*" && echo -e "${NC}"
}

function __msg_warning() {
    [[ "${WARNING}" == "1" ]] && echo -e "${YELLOW}[WARNING]: $*" && echo -e "${NC}"
}

function __msg_info() {
    [[ "${INFO}" == "1" ]] && echo -e "${GREEN}[INFO]: $*" && echo -e "${NC}"
}

function askInstallMasternode(){

	if [ -d "$MASTERNODE_TARGET_FOLDER" ]; 
		then #Masternode-folder already exists?
		echo ''
			while true; do

			case $(promptValue "Masternode-folder already exists, continue and overwrite?(y/n)" "y") in 
			  y|Y )
			   
                installMasternode
				
			    break ;;
			  n|N )
					__msg_warning "Installation skipped by user"

                    exit ${INSTALLATION_ABORTED}
					break ;;
			  * ) 	__msg_warning "Invalid input"
					echo -e "${NC}";;
			esac
	    done
	else
		installMasternode
	fi
}

function installMasternode(){
    wget -P /tmp $MASTERNODE_DOWNLOAD_URL
    tar -xvzf /tmp/$MASTERNODE_ARCHIVE -C /tmp/
    mkdir -p "$MASTERNODE_TARGET_FOLDER"
    rm -r "${MASTERNODE_TARGET_FOLDER:?}/"*
    cp -R /tmp/$MASTERNODE_RELEASE_FOLDER/* "$MASTERNODE_TARGET_FOLDER"
}

#_start________________________________________________________________________

if [ "$EUID" -ne 0 ]
  then echo "Please execute as root"
  exit ${NO_ROOT}
fi

clear

askInstallMasternode

