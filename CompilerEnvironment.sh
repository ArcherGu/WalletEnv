#!/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
BLUE='\033[01;34m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
MAX=6

checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..."
    if [[ `cat /etc/issue.net`  == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
        echo && echo "Installation cancelled" && echo;
        exit;
    fi
}

updateAndUpgrade() {
    echo
    echo "[2/${MAX}] Runing update and upgrade. Please wait..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null 2>&1
    echo -e "${GREEN}* Completed${NONE}";
}

setupSwap() {
    echo -e "${BOLD}"
    read -e -p "Add swap space? (If you use a 1G RAM VPS, choose Y.) [Y/n] :" add_swap
    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        swap_size="4G"
    else
        echo -e "${NONE}[3/${MAX}] Swap space not created."
    fi

    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        echo && echo -e "${NONE}[3/${MAX}] Adding swap space...${YELLOW}"
        sudo fallocate -l $swap_size /swapfile
        sleep 2
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo -e "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
        sudo sysctl vm.swappiness=10
        sudo sysctl vm.vfs_cache_pressure=50
        echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "${NONE}${GREEN}* Completed${NONE}";
    fi
}

installFail2Ban() {
    echo -e "${BOLD}"
    read -e -p "Install Fail2Ban? (This is just a safety program, optional.) [Y/n] :" install_F2B
    if [[ ("$install_F2B" == "y" || "$install_F2B" == "Y" || "$install_F2B" == "") ]]; then
        echo -e "[4/${MAX}] Installing fail2ban. Please wait..."
        sudo apt-get -y install fail2ban > /dev/null 2>&1
        sudo systemctl enable fail2ban > /dev/null 2>&1
        sudo systemctl start fail2ban > /dev/null 2>&1
        echo -e "${NONE}${GREEN}* Completed${NONE}";
    else
        echo -e "${NONE}[4/${MAX}] Fail2Ban not installed."
    fi
}

installFirewall() {
    echo -e "${BOLD}"
    read -e -p "Install Firewall? (This is just for safety, optional.) [Y/n] :" install_FW
    if [[ ("$install_FW" == "y" || "$install_FW" == "Y" || "$install_FW" == "") ]]; then
        echo -e "[5/${MAX}] Installing UFW. Please wait..."
        sudo apt-get -y install ufw > /dev/null 2>&1
        sudo ufw default deny incoming > /dev/null 2>&1
        sudo ufw default allow outgoing > /dev/null 2>&1
        sudo ufw allow ssh > /dev/null 2>&1
        sudo ufw limit ssh/tcp > /dev/null 2>&1
        #sudo ufw allow $COINPORT/tcp > /dev/null 2>&1
        #sudo ufw allow $COINRPCPORT/tcp > /dev/null 2>&1
        sudo ufw logging on > /dev/null 2>&1
        echo "y" | sudo ufw enable > /dev/null 2>&1
        echo -e "${NONE}${GREEN}* Completed${NONE}";
    else
        echo -e "${NONE}[5/${MAX}] Firewall not installed."
    fi
}

installDependencies() {
    echo
    echo -e "[6/${MAX}] Installing dependecies. Please wait..."
    sudo apt-get install git nano rpl wget python-virtualenv -qq -y > /dev/null 2>&1
    sudo apt-get install build-essential libtool automake autoconf -qq -y > /dev/null 2>&1
    sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -qq -y > /dev/null 2>&1
    sudo apt-get install software-properties-common python-software-properties -qq -y > /dev/null 2>&1
    sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
    sudo apt-get update -qq -y > /dev/null 2>&1
    sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libminiupnpc-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libzmq5 -qq -y > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}


clear
cd

echo -e "${BOLD}"
read -p "This script will setup your VPS for MasterNode setting up. Do you wish to continue? (y/n)?" response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    checkForUbuntuVersion
    updateAndUpgrade
    setupSwap
    installFail2Ban
    installFirewall
    installDependencies
    echo
    echo -e "${BOLD}Your VPS has been set up, then you can set MasterNode on your VPS.${NONE}"
    echo

else
    echo && echo "Installation cancelled" && echo
fi
