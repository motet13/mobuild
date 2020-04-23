#!/bin/bash
<<<<<<< HEAD

=======
>>>>>>> bcb6c54ce61975436b89ccdcd6e3c8fdde134c5d
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
<<<<<<< HEAD
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
=======

# list of wanted packages to be installed
# may edit mylist.txt file to fit your needs
list=$(cat mylist.txt)

echo
echo -e "$gry ------------------- "
echo -e "$gry     installed ==> $grn+$gry"
echo -e " not installed ==> $red-$dflt"
echo -e "$gry ------------------- $dflt"
>>>>>>> bcb6c54ce61975436b89ccdcd6e3c8fdde134c5d
echo

echo -e " Package:Status" > logs/result.log
echo -e " -------:------" >> logs/result.log
echo

<<<<<<< HEAD
# Check if listed package in $package is installed in the system

for i in $(jq -r '.package[]' $package)
do
    dpkg -s $i &> /dev/null

    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]" >> logs/result.log
    else
        echo -e " $i:[$red - $dflt]" >> logs/result.log
        not_installed+=("$i")
=======
# Check if listed package in mylist.txt is installed in the system
for i in $list; do
    dpkg -s $i &> /dev/null 
    
    if [ $? == 0 ]; then
        echo -e " $i:[$grn + $dflt]" >>logs/result.log 
    else
        echo -e " $i:[$red - $dflt]" >> logs/result.log
        echo -e " $i" >> missing.tmp # redirect not installed
>>>>>>> bcb6c54ce61975436b89ccdcd6e3c8fdde134c5d
    fi
done

# Output result on screen
column -s: -t logs/result.log
echo
echo

<<<<<<< HEAD
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
=======
# Output missing.log on screen if there is any
missing=$(cat missing.tmp)
if [ -s missing.tmp ]; then 
    echo -e "$gry Please install missing Package(s) $dflt"
    echo $missing | tee logs/missing.log
fi

# Ask to install missing packages
read -n1 -p "Would you like to install missing package(s) [Y/n]? " answer
case $answer in
    Y | y) echo
        for i in $missing; do
            echo -en "$grn [ installing ] $gry $i"
            echo
#            apt install $i
        done;;
    N | n) echo
        echo OK, goodbye
        true > missing.tmp
        exit;;
    *)
        echo
        echo "Sorry, wrong selection"
        true > missing.tmp
        exit;;
esac

# empty missing.log file
true > missing.tmp
echo
echo -en "$gry Starting to configure"

# Just a little "..." wait animation
for i in $(seq 1 3);do
    dot= echo -en "."
    echo -en $dot   
    sleep 1
done

echo

echo
echo -e "$gry -------------- Build my Vim --------------- "
echo -e "If Vim is installed but not configured for using Vundle, fix it!"
echo

# make directories in .vim containing bundle, colors, templates
myvim="$(cat logs/result.log | grep vim | awk '{print $2}')"
dir_list=(~/.vim/bundle ~/.vim/colors ~/.vim/templates)
if [ $myvim == '+' ]; then
    for i in "${dir_list[@]}"; do
        echo -e "$grn [ mkdir ] $gry $i"     
#        mkdir -p -v $i                                                                                                                     
    done
fi 

# download colorschemes
scheme_list=(https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
https://raw.githubusercontent.com/sjl/badwolf/master/colors/badwolf.vim)

for i in "${scheme_list[@]}"; do
    file=$(echo $i | sed 's/\// /g' | awk '{print $NF}')
    echo -e "$grn [ Downloading ] $gry $i"
#    curl -o ~/.vim/colors/$file $i 
done

# Create templates (templates will be applied when starting particular file in
# vim). This will just simply copy the skeleton files from templates directory
# to your ~/.vim/templates directory. You can edit skeleton files to your
# likings.
for i in $(ls templates); do
    echo -e "$grn [ Copying ] $gry $i"
#    cp templates/$i ~/.vim/templates
done

### Problem to solve.
### How do i know if vim is not configured to use Vundle!
### think! think! think!

# Download Vundle.vim if not installed else exit
# Insert recommended Vundle settings in .vimrc
# copy original .vimrc first

# function to configure vim if it's not configured to use Vundle.
vimconf() {
    # [testing] 
    # real path to .vimrc is ~/.vimrc
    cp vimconf/.vimrc vimconf/.vimrc_old
    cat vimconf/vim_template vimconf/.vimrc > vimconf/tmprc
    cp vimconf/tmprc vimconf/.vimrc
    true > vimconf/tmprc
}

# [testing] don't forget to change isvundle value to ~/.vim/bundle/Vundle.vim
isvundle=~/bin/mobuild/vimconf/bundle/Vundle.vim
isvundleconf=$(cat ~/.vimrc | grep -o 'VundleVim/Vundle.vim')

if [ -e $isvundle ]; then
    echo "Vundle.vim is already installed in $isvundle" 
    echo -en "Checking if it's configured to use Vundle..."
    if [ $isvundleconf == 'VundleVim/Vundle.vim' ]; then
        echo -e "$grn [ Okay ] $gry"
    else
        echo -en "$grn [ Cloning ] $gry"
        git clone https://github.com/VundleVim/Vundle.vim.git ~/bin/mobuild/vimconf/bundle/Vundle.vim
        vimconf
    fi
else
    vimconf
fi

echo
echo "If you want, copy vimconf/vimplugn.txt contents and paste it in ~/.vimrc
after the line Plugin 'VundleVim/Vundle.vim'. Then open vim and run
:PluginInstall."

#echo -e "$dflt Done!"
echo
echo "Tip: Change ~/.vim and ~/.vimrc ownership from root to USER."
echo 'Run sudo chown -R $USER: ~/.vim ~/.vimrc'

#cp -R vimconf/.vim ~/
#cp -R vimconf/.vimrc ~/ 

#if [ $? == 0 ]; then
#    echo -e "$dflt Done!"
#else
#    echo -e "$red Error!"
#fi
#echo
>>>>>>> bcb6c54ce61975436b89ccdcd6e3c8fdde134c5d
