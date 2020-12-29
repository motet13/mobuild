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
apt_install=()
snap_install=()

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
                if [[ $(jq -r '.snap_packages[]' $package | grep -w $i) == $i ]]; then
                    snap_install+=("$i")

                elif [[ $(jq -r '.package[]' $package | grep -w $i) == $i ]]; then
                    apt_install+=("$i")
                    
                elif [[ $(jq -r '.apt_add_repos[]' $package | grep -w $i) == $i ]]; then
                	if [[ $i == 'sublime-text' ]]; then
                  		echo -en "$grn [ downloading ]$dflt $(jq -r '.sublime[0]' $package)..."
                    	wget -qO - $(jq -r '.sublime[0]' $package) | sudo apt-key add -
                    	echo -en "$grn [ checking deb ]$dflt $(jq -r '.sublime[1]' $package)..."
                    	check_deb $(jq -r '.sublime[1]' $package)
                    	echo -en "$grn [ adding repository ]$dflt $(jq -r '.sublime[2]' $package)..."
                    	echo $(jq -r '.sublime[2]' $package) | sudo tee /etc/apt/sources.list.d/sublime-text.list >> logs/apt_install.log 2>&1
                    	show_status
                        apt_install+=("$i")

                	elif [[ $i == 'code' ]]; then
                		echo -en "$grn [ downloading ]$dflt $(jq -r '.vscode[0]' $package)..."
                    	wget -qO - $(jq -r '.vscode[0]' $package) | gpg --dearmor > packages.microsoft.gpg
                    	install -o root -g root -m 644 $(jq -r '.vscode[1]' $package)
                    	show_status
                    	echo -en "$grn [ checking deb ]$dflt $(jq -r '.vscode[3]' $package)..."
                    	check_deb $(jq -r '.vscode[3]' $package)
                    	echo -en "$grn [ adding repository ]$dflt $(jq -r '.vscode[2]' $package)..."
                    	echo $(jq -r '.vscode[2]' $package) | sudo tee /etc/apt/sources.list.d/vscode.list >> logs/apt_install.log 2>&1
                    	show_status
                        apt_install+=("$i")

                    elif [[ $i == 'papirus-icon-theme' ]]; then
                        echo -en "$grn [ adding repository ]$dflt $(jq -r '.papirus[0]' $package)..."
                        sudo add-apt-repository -y $(jq -r '.papirus[0]' $package) >> logs/apt_install.log 2>&1
                        show_status
                        apt_install+=("$i")
                    fi
                fi 
            done
            break;;
        N | n) echo
            echo " OK, moving on without installing..."
            exit 1
            break;;
        *)
            echo
            echo " Sorry, wrong selection";;
    esac
done

echo -en "$grn [ apt-get update ]$dflt ..."
apt-get update >> logs/apt_install.log 2>&1
show_status
echo -en "$grn [ snap install ]$dflt ${snap_install[@]}..."
snap install ${snap_install[@]} >> logs/apt_install.log 2>&1
show_status
echo -en "$grn [ apt install ]$dflt ${apt_install[@]}..."
apt-get install -y ${apt_install[@]} >> logs/apt_install.log 2>&1
show_status
echo
echo " Run vimconfig.sh to setup vim."

echo
echo " Last ran: $date at $time"