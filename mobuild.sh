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

for pk in $(jq -r '.package[], .snap_packages[], .apt_add_repos[]' $package); do
    dpkg -s $pk &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $pk:[$grn + $dflt]:apt" >> logs/result.log
    else   
        not_installed+=("$pk")     
    fi
done

for pk in ${not_installed[@]}; do
    snap list $pk &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $pk:[$grn + $dflt]:snap" >> logs/result.log
        not_installed=("${not_installed[@]/$pk}")
    else
        echo -e " $pk:[$red - $dflt]:" >> logs/result.log
    fi
done

# Output result on screen

column -s: -t logs/result.log
echo

# Output not installed packages on screen if there is any

if [[ $(echo ${not_installed[@]} | wc -w) == 0 ]]; then
    echo " All packages listed in $package have already been installed into your system."
    exit
fi

echo " Total package(s) not installed: $(echo ${not_installed[@]} | wc -w)"

echo -e " Please install missing Package(s)"

for i in ${not_installed[@]}
do
    echo -e "$red $i $dflt"
done
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

check_deb() {
    dpkg -s $1 &> /dev/null
    if [[ $? == 0 ]]; then
        echo -e "$grn Okay$dflt"
    else
        apt-get install $1 >> logs/apt_install.log 2>&1
        show_status
    fi  
}
while true
do
    read -p " Would you like to install missing package(s) [Y/n]? " answer
    case $answer in
        Y | y) echo
            for i in ${not_installed[@]}; do
                if [[ $(jq -r '.snap_packages[]' $package | grep $i) == $i ]]; then
                    echo -en "$grn [ installing ]$dflt snap install $i..."
                    snap install $i >> logs/apt_install.log 2>&1

                    show_status
                fi

                if [[ $(jq -r '.package[]' $package | grep $i) == $i ]]; then
                    echo -en "$grn [ installing ]$dflt apt install $i..."
                    apt-get install $i -y >> logs/apt_install.log 2>&1
                    show_status
                fi
                    
                if [[ $(jq -r '.apt_add_repos[]' $package | grep $i) == $i ]]; then
                	if [[ $i == 'sublime-text' ]]; then
                  		echo -en "$grn [ downloading ]$dflt $(jq -r '.sublime[0]' $package)..."
                    	wget -qO - $(jq -r '.sublime[0]' $package) | sudo apt-key add -
                    	echo -en "$grn [ checking deb ]$dflt $(jq -r '.sublime[1]' $package)..."
                    	check_deb $(jq -r '.sublime[1]' $package)
                    	echo -en "$grn [ adding repository ]$dflt $(jq -r '.sublime[2]' $package)..."
                    	echo $(jq -r '.sublime[2]' $package) | sudo tee /etc/apt/sources.list.d/sublime-text.list >> logs/apt_install.log 2>&1
                    	show_status
                    	echo -en "$grn [ updating ]$dflt ..."
                    	apt-get update >> logs/apt_install.log 2>&1
                    	show_status
                    	echo -en "$grn [ installing ]$dflt $i..."
                    	apt-get install sublime-text >> logs/apt_install.log 2>&1
                    	show_status
                    fi

                	if [[ $i == 'code' ]]; then
                		echo -en "$grn [ downloading ]$dflt $(jq -r '.vscode[0]' $package)..."
                    	wget -qO - $(jq -r '.vscode[0]' $package) | gpg --dearmor > packages.microsoft.gpg
                    	install -o root -g root -m 644 $(jq -r '.vscode[1]' $package)
                    	show_status
                    	echo -en "$grn [ checking deb ]$dflt $(jq -r '.vscode[2]' $package)..."
                    	check_deb $(jq -r '.vscode[2]' $package)
                    	echo -en "$grn [ adding repository ]$dflt $(jq -r '.vscode[3]' $package)..."
                    	echo $(jq -r '.vscode[3]' $package) | sudo tee /etc/apt/sources.list.d/vscode.list >> logs/apt_install.log 2>&1
                    	show_status
                    	echo -en "$grn [ updating ]$dflt ..."
                    	apt-get update >> logs/apt_install.log 2>&1
                    	show_status
                    	echo -en "$grn [ installing ]$dflt $i..."
                    	apt-get install code >> logs/apt_install.log 2>&1
                    	show_status
                    fi
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
echo
echo " Run vimconfig.sh to setup vim."

echo
echo " Last ran: $date at $time"