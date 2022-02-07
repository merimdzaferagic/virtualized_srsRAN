#!/bin/bash

#    goDASH, DASH video streaming application written in golang
#    Copyright (c) 2020, Darijo Raca, Maëlle Manifacier, John O'Sullivan, Jason Quinlan
#    University College Cork
#    MISL Summer of Code 2019
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation; either version 2
#    of the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#    02110-1301, USA.
#
#We kindly ask that should you mention godash or godashbed or use our code in your publication, that you would reference the following papers:
#
#D. Raca, M. Manifacier, and Jason J. Quinlan.  goDASH - GO accelerated HAS framework for rapid prototyping. 12th International Conference on Quality of Multimedia Experience (QoMEX), Athlone, Ireland. 26th to 28th May, 2020
#
#John O’Sullivan, D. Raca, and Jason J. Quinlan.  Demo Paper: godash 2.0 - The Next Evolution of HAS Evaluation. 21st IEEE International Symposium On A World Of Wireless, Mobile And Multimedia Networks (IEEE WoWMoM 2020), Cork, Ireland. August 31 to September 03, 2020

# version 1.0.21 - 04-08-2020
# update to godash - header requests for arbiter/bba

GO_VERSION=1.13.8
GODASH_VERSION=2.2
GODASHBED_VERSION=2.0.2
D_ITG_VERSION=2.8.1
CONSUL_VERSION=1.7.3
INSTALL_SCRIPT_VERISON=1.0.20

# installed folders:
INSTALLED_FOLDERS=("goDASH" "goDASHbed" "mininet" "openflow" "/usr/local/go/" "D-ITG-${D_ITG_VERSION}-r1023" "itu-p1203")
# maybe use index slicing to make the installed_folder usable as an update_folder
UPDATE_FOLDERS=("goDASH" "goDASHbed" "mininet")

# string checks
go_dash_string="godash"
help_string="help"
all_string="all"
remove_string="remove"
update_string="update"

# error message
stop_script () {
    echo ""
    echo "### THE goDASH/goDASHbed install script requires 1 parameter ###"
    echo ""
    echo "### Parameters are case sensitive ###"
    echo ""
    echo "To print this help screen use:"
    echo "./install_v"${INSTALL_SCRIPT_VERISON}"_ubuntu_20.04.sh "${help_string}
    echo ""
    echo "To install just goDASH and go, use:"
    echo "./install_v"${INSTALL_SCRIPT_VERISON}"_ubuntu_20.04.sh "${go_dash_string}
    echo ""
    echo "To install both goDASH and goDASHbed"
    echo "and all dependencies (mininet/go/D-ITG) use:"
    echo "./install_v"${INSTALL_SCRIPT_VERISON}"_ubuntu_20.04.sh "${all_string}
    echo ""
    echo "To remove both goDASH and goDASHbed"
    echo "and all dependencies (mininet/go/D-ITG) use:"
    echo "./install_v"${INSTALL_SCRIPT_VERISON}"_ubuntu_20.04.sh "${remove_string}
    echo ""
    echo "To upgrade both goDASH and goDASHbed"
    echo "and all dependencies (mininet) use:"
    echo "./install_v"${INSTALL_SCRIPT_VERISON}"_ubuntu_20.04.sh "${update_string}
    echo ""
    echo "This will overwrite any changes in your copy of goDASH/goDASHbed/mininet"
    echo "so only use for a clean update..."
    echo ""
    echo "It is always best to get the newest version of the install script"
    echo "just in case we add some new features..."
    echo ""
    exit 1
}

# error message
stop_removal () {
    echo ""
    echo "Probably a good idea to stop the remove."
    echo "It is easy enough to do this manually."
    echo "It might be best to open the script in a text editor and follow the removal steps"
    # stop
    exit 1
}

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
# echo $SCRIPTPATH

# print out error message if the script is called with no parameters
if ! [ $# -eq 1 ]
then
    stop_script
fi

# print out error message if the parameters are wrong
if [ $1 != ${go_dash_string} ] && [ $1 != ${all_string} ] && [ $1 != ${help_string} ] && [ $1 != ${remove_string} ] && [ $1 != ${update_string} ]
then
    stop_script
fi

# help message
if [ $1 == ${help_string} ]
then
    stop_script
fi

# remove godash/godashbed/go/mininet/D-ITG - TO TEST
if [ $1 == ${remove_string} ]
then
    # if goDASH is not installed, then something is wrong, so don't remove all folders
    if ! [ -d goDASH  ]
    then
        echo ""
        echo "### godash is not installed, so stopping removal of godash and associated folders ###"
        echo ""
    # remove dependencies for goDASH(bed)
    else
        echo ""
        echo "### elements of the install such as: ###"
        echo "### godash/godashbed/go/mininet/D-ITG/itu-p1203 are being removed ###"
        echo ""
        echo "Modification to a standard install can cause issues during removal"
        echo "By typing 'accept', you accept that problems can occur and you take full responsibility for any issues that could occur."
        echo ""
        read -p "Enter 'accept' to accept or just hit the return key to stop: " varname
        if ! [ -n "$varname" ]; then
            stop_removal
        else
            varname=${varname// /_}
            varname=`echo "$varname" | tr '[:upper:]' '[:lower:]'`
            echo $varname
            if [ "$varname" = "accept" ]
            then
                echo "Excellent, let's remove the installation."
                echo "Hope you enjoyed playing with godash/godashbed."
        
                # remove P1203 from the system
                if [ -d itu-p1203/  ]
                then
                    cd itu-p1203/
                    pip3 uninstall itu_p1203
                    cd ..
                fi
                
                # now remove the folders
                for local_folder in ${INSTALLED_FOLDERS[@]}; do
                    if [ -d $local_folder  ]
                    then
                        echo "removing $local_folder"
                         rm -Rf $local_folder
                    fi
                done
                
                # remove consul
                 rm /usr/local/bin/consul
            
                # remove the testbed server from /etc/hosts
                # echo "10.0.0.1   www.godashbed.org" |  tee -a /etc/hosts
                 sed -i 's|10.0.0.1   www.godashbed.org||g' /etc/hosts
                
                # remove go from bashrc
                # echo export GOROOT=/usr/local/go >> $HOME/.bashrc
                GOROOT=/usr/local/go
                sed -i "s|export GOROOT=$GOROOT||g" $HOME/.bashrc
                # echo export GOPATH=$SCRIPTPATH/goDASH >> $HOME/.bashrc
                GOPATH=$SCRIPTPATH/goDASH
                sed -i "s|export GOPATH=$GOPATH||g" $HOME/.bashrc
                # echo export PATH='''$PATH:$GOROOT/bin:$GOPATH/bin''' >> $HOME/.bashrc
                sed -i 's|export PATH=$PATH:$GOROOT/bin:$GOPATH/bin||g' $HOME/.bashrc
                source $HOME/.bashrc
                
                # update source for this terminal
                . ~/.bashrc
            else
                stop_removal
            fi
        fi
    fi
    
    # stop
    exit 1
fi

# update godash/godashbed/go/mininet - TODO
if [ $1 == ${update_string} ]
then
    echo "Coming soon... update has not yet been implemented"
    exit 1
fi

# clone goDASH
if [ -d goDASH  ] && [ $1 == ${all_string} ]
then
    echo ""
    echo "### godash is already installed, so ignoring new install of godash and go ###"
    echo ""
# install dependencies for goDASH(bed)
elif [ $1 == ${go_dash_string} ] || [ $1 == ${all_string} ]
then

    # check the operating system
    unamestr=`uname`
    if [[ "$unamestr" != 'Linux' ]]; then
        echo ""
        echo "### This install script works best on Linux (Ubuntu 20.04) ###"
        echo "### Please modify if you would like to install on a different O/S ###"
        echo ""
        exit 1
    fi
    
    # clone goDASH
    if [ -d goDASH  ] && [ $1 == ${go_dash_string} ]
    then
        echo ""
        echo "### godash is already installed, please remove the older verison ###"
        echo "### before installing this version -" ${GODASH_VERSION} "###"
        echo ""
        exit 1
    fi
    
    # updated for Ubuntu 20.04
    echo ""
    echo "### Installing software dependencies ###"
    echo ""
     apt install net-tools build-essential git python3-pip sed unzip -y
     pip3 install pandas
     pip3 install numpy
     pip3 install matplotlib
    
    # install the ASGI Server - Hypercorn/Quart - with HTTP/3 (QUIC) support
     pip3 install hypercorn[h3]==0.10.2
     pip3 install Quart
     python3 -m pip install -U quart-trio
     python3 -m pip install -U trio
    
    # install caddy v2
    echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    |  tee -a /etc/apt/sources.list.d/caddy-fury.list
     apt update
     apt install caddy

    #  download go
    if [ -d /usr/local/go  ]
    then
        echo ""
        echo "### Google GO is already installed, please remove the older verison ###"
        echo "### before installing this version -" ${GO_VERSION} "###"
        echo ""
        exit 1
    fi
    
    echo ""
    echo "### Installing go version -" ${GO_VERSION} "###"
    echo ""
    wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
     tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    rm go${GO_VERSION}.linux-amd64.tar.gz

    # if you want to install golang on OSX, use this:
    # curl -o golang.pkg https://dl.google.com/go/go${GO_VERSION}.darwin-amd64.pkg
    #  open golang.pkg
    # and follow the install steps
    
    echo ""
    echo "### Installing the QoE Standard - P.1203 ###"
    echo ""
    # P1203 has to be installed for root, as this is a requirement of mininet...
    git clone http://github.com/itu-p1203/itu-p1203.git
    cd itu-p1203/
     pip3 install .
     python3 -m itu_p1203 examples/mode0.json
    cd ..
    
    # create sim link to p1203-standalone, as xterm does not read from $HOME/.local/bin
     ln -s $HOME/.local/bin/p1203-standalone /usr/local/bin/p1203-standalone
    
    echo ""
    echo "### Installing consul version -" ${CONSUL_VERSION} "###"
    echo ""
    wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip
     mv consul /usr/local/bin/
    rm consul_${CONSUL_VERSION}_linux_amd64.zip
    
    echo ""
    echo "### Installing godash version -" ${GODASH_VERSION} "###"
    echo ""
    
    # lets make a storage folder
    mkdir goDASH
    cd ./goDASH
    # lets clone the godash repo
    git clone https://github.com/uccmisl/godash.git
    # move into the repo
    cd godash
    git checkout v${GODASH_VERSION}
    
    # add path to go in bashrc
    echo export GOROOT=/usr/local/go >> $HOME/.bashrc
    echo export GOPATH=$SCRIPTPATH/goDASH >> $HOME/.bashrc
    echo export PATH='''$PATH:$GOROOT/bin:$GOPATH/bin''' >> $HOME/.bashrc
    source $HOME/.bashrc

    export GOROOT=/usr/local/go
    export GOPATH=$SCRIPTPATH/goDASH
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

    # update source for this terminal
    . ~/.bashrc
    
    # build the godash player
    go build

    # stop the script if this install is only goDASH
    if [ $1 == ${go_dash_string} ]
    then
        exit 1
    fi
    
    cd $SCRIPTPATH
fi

# install dependencies for goDASHbed
if [ -d goDASHbed  ] && [ $1 == ${all_string} ]
then
    echo ""
    echo "### goDASHbed is already installed, please remove the older verison ###"
    echo "### before installing this version -" ${GODASHBED_VERSION} "###"
    echo ""
    exit 1
elif [ $1 == ${all_string} ]
then
    echo ""
    echo "### Installing goDASHbed version -" ${GODASHBED_VERSION} "###"
    echo ""
    
    # clone mininet repo
    git clone git://github.com/mininet/mininet

    # cd into folder
    cd mininet/util

    # force mininet to use python3
    sed -i 's/PYTHON=${PYTHON:-python}/PYTHON=${PYTHON:-python3}/g' ./install.sh

    # install mininet with minimum options
    echo ""
    echo "### Installing mininet ###"
    echo ""
    ./install.sh -nfv

    cd $SCRIPTPATH

    # download goDASHbed
    git clone https://github.com/uccmisl/goDASHbed.git
    cd goDASHbed
    git checkout v${GODASHBED_VERSION}
    
    cd $SCRIPTPATH
    
    # update the caddy2 tls cert locations
    sed -i "s|<godash folder location>|$SCRIPTPATH|g" ./goDASHbed/caddy-config/TestbedTCP/CaddyFilev2TCP
    sed -i "s|<godash folder location>|$SCRIPTPATH|g" ./goDASHbed/caddy-config/TestbedTCP/CaddyFilev2QUIC

    # link godashbed.org to IP address in Ubuntu
    echo "10.0.0.1   www.godashbed.org" |  tee -a /etc/hosts

    # install apache, so we can host content in /var/www
    echo ""
    echo "### Installing apache2 ###"
    echo ""
     apt install apache2 -y

    # add the voip generator for goDAShbed
    echo ""
    echo "### Installing D-ITG-${D_ITG_VERSION}-r1023 ###"
    echo ""
    wget http://cs1dev.ucc.ie/misl/goDASH/D-ITG-${D_ITG_VERSION}-r1023.zip
    unzip D-ITG-${D_ITG_VERSION}-r1023.zip
    rm D-ITG-${D_ITG_VERSION}-r1023.zip
    cd D-ITG-${D_ITG_VERSION}-r1023/src
    make
     make install
fi

# note: log out and log in again may be needed for terminal to link to the go executible...
