#!/bin/bash

#
#if [ $UID != 0 ]; then
#    echo "Please run as sudo!"
#    echo "sudo $0"
#    exit 1
#fi

# text output color
grn="\e[32m"
dflt="\e[39m"
red="\e[91m"
gry="\e[90m"
not_installed=()

date=$(date +%y/%m/%d)
time=$(date +%H:%M:%S)

package=conf/package.json

# list of wanted packages to be installed
# may edit $package file to fit your needs
#list=$(cat mylist.txt)

echo
echo -e " ------------------- "
echo -e "     installed ==> $grn+$dflt"
echo -e " not installed ==> $red-$dflt"
echo -e " ------------------- $dflt"
echo

echo -e " Package:Status" > logs/result.log
echo -e " -------:------" >> logs/result.log
echo

# Check if listed package in $package is installed in the system

for i in $(jq -r '.package[]' $package)
do
    dpkg -s $i &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]" >> logs/result.log
    else
        echo -e " $i:[$red - $dflt]" >> logs/result.log
        not_installed+=("$i")
    fi
done

# Output result on screen
column -s: -t logs/result.log
echo
echo

# Output not installed packages on screen if there is any
echo -e " Please install missing Package(s)"

for i in ${not_installed[@]}
do
    echo -e "$red $i $dflt"
done
echo
echo
# Ask to install missing packages
while true
do
    read -p " Would you like to install missing package(s) [Y/n]? " answer
    case $answer in
        Y | y) echo
            for i in ${not_installed[@]}; do
                if [[ $i != 'sublime-text' ]]; then
                    echo -en "$grn [ installing ]$dflt $i..."
                    apt-get install $i -y >> logs/apt_install.log 2>&1

                    if [[ $? != 0 ]]; then
                        echo -en "$red[ Error ]$dflt Please review apt_install.log"
                        echo
                    else
                        echo -e "Okay"
                    fi
                else
                    # [ TESTING ]
                    echo -en "$grn [ installing ]$dflt sublime-text..."
                    # wget -qO - $(jq -r '.sublime[0]' $package) | sudo apt-key add -
                    # sudo apt-get install $(jq -r '.sublime[1]' $package) >> logs/apt_install.log 2>&1
                    # echo $(jq -r '.sublime[2]' $package) | sudo tee /etc/apt/sources.list.d/sublime-text.list
                fi
            done
            break;;
        N | n) echo
            echo " OK, moving on without installing..."
            break;;
        *)
            echo
            echo " Sorry, wrong selection";;
    esac
done

echo " Run vim_setup.sh then run xplugn.sh"

echo
echo " Last ran: $date at $time"
