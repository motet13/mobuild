#!/bin/bash

# if [ $UID != 0 ]; then
#    echo "Please run as sudo!"
#    echo "sudo $0"
#    exit 1
# fi

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

echo -e " Package:Status:Install" > logs/result.log
echo -e " -------:------:-------" >> logs/result.log
echo

# Check if listed package in $package is installed in the system

for i in $(jq -r '.package[]' $package)
do
    dpkg -s $i &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]:apt" >> logs/result.log
    else
        echo -e " $i:[$red - $dflt]:apt" >> logs/result.log
        not_installed+=("$i")
    fi
done

# Snaps
for i in $(jq -r '.snap_packages[]' $package)
do
    snap list $i &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]:snap" >> logs/result.log
    else
        echo -e " $i:[$red - $dflt]:snap" >> logs/result.log
        not_installed+=("$i")
    fi
done

# apt-add-repos
for i in $(jq -r '.apt_add_repos[]' $package)
do
    dpkg -s $i &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]:apt" >> logs/result.log
    else
        echo -e " $i:[$red - $dflt]:apt" >> logs/result.log
        not_installed+=("$i")
    fi
done

# for i in ${not_installed[@]}; do
#     if [ $(jq -r '.snap_packages[]' $package | grep $i | echo $?) == 0 ]; then
#         echo "SNAP"
#     fi
# done

# Output result on screen
column -s: -t logs/result.log
echo
echo

# Output not installed packages on screen if there is any

if [ $(echo $not_installed | wc -w) == 0 ]; then
    echo " All packages listed in $package have already been installed into your system."
    exit
fi

echo -e " Please install missing Package(s)"

for i in ${not_installed[@]}
do
    echo -e "$red $i $dflt"
done
echo
echo

# Ask to install missing packages

show_status() {
    if [[ $? != 0 ]]; then
        echo -en "$red [ Error ]$dflt Please review apt_install.log"
        echo
    else
        echo -e "$grn Okay$dflt"
    fi    
}

while true
do
    read -p " Would you like to install missing package(s) [Y/n]? " answer
    case $answer in
        Y | y) echo
            for i in ${not_installed[@]}; do
                if [[ $(jq -r '.snap_packages[]' $package | grep $i) == $i ]]; then
                    echo -en "$grn [ installing ]$dflt $i..."
                    snap install $i >> logs/apt_install.log 2>&1
                    # echo " Installing $i from snap"

                    show_status

                elif [[ $(jq -r '.package[]' $package | grep $i) == $i ]]; then
                    echo -en "$grn [ installing ]$dflt $i..."
                    apt-get install $i -y >> logs/apt_install.log 2>&1
                    # echo "Installing $i from apt"

                    show_status

                elif [[ $(jq -r '.apt_add_repos[]' $package | grep 'sublime-text') == 'sublime-text' ]]; then
                    echo -en "$grn [ installing ]$dflt $i..."
                    wget -qO - $(jq -r '.sublime[0]' $package) | sudo apt-key add -
                    apt-get install $(jq -r '.sublime[1]' $package) >> logs/apt_install.log 2>&1
                    echo $(jq -r '.sublime[2]' $package) | sudo tee /etc/apt/sources.list.d/sublime-text.list
                    apt-get update >> logs/apt_install.log 2>&1
                    apt-get install sublime-text >> logs/apt_install.log 2>&1
                
                    show_status
                fi

                # elif [[ $i != 'sublime-text' ]]; then
                #     echo -en "$grn [ installing ]$dflt $i..."
                #     apt-get install $i -y >> logs/apt_install.log 2>&1

                #     if [[ $? != 0 ]]; then
                #         echo -en "$red [ Error ]$dflt Please review apt_install.log"
                #         echo
                #     else
                #         echo -e "$grn Okay$dflt"
                #     fi
                # else
                #     echo -en "$grn [ installing ]$dflt sublime-text..."
                #     wget -qO - $(jq -r '.sublime[0]' $package) | sudo apt-key add -
                #     apt-get install $(jq -r '.sublime[1]' $package) >> logs/apt_install.log 2>&1
                #     echo $(jq -r '.sublime[2]' $package) | sudo tee /etc/apt/sources.list.d/sublime-text.list
                #     apt-get update >> logs/apt_install.log 2>&1
                #     apt-get install sublime-text >> logs/apt_install.log 2>&1
                # fi
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
echo
echo " Run vimconfig.sh to setup vim."

echo
echo " Last ran: $date at $time"
