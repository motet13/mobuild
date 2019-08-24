#!/bin/bash

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

# list of wanted packages to be installed
list=$(cat mylist.txt)

echo
echo -e "$gry ------------------- "
echo -e "$gry     installed ==> $grn+$gry"
echo -e " not installed ==> $red-$dflt"
echo -e "$gry ------------------- $dflt"
echo

echo -e "Package:Status" > result.log
echo -e "-------:------" >> result.log
echo

# Check if listed package in mylist is installed in the system
for i in $list; do
    dpkg -s $i &> /dev/null 
    
    if [ $? == 0 ]; then
        echo -e "$i:[$grn + $dflt]" >> result.log 
    else
        echo -e "$i:[$red - $dflt]" >> result.log
        echo -e "$i" >> missing.tmp # redirect not installed
    fi
done

# Output result on screen
column -s: -t result.log
echo
echo

#Output missing.log on screen if there is any
if [ -s missing.tmp ]; then 
    echo -e "$gry Please install missing Package(s) $dflt"
    cat missing.tmp | tee missing.log
fi

# empty missing.log file
> missing.tmp
echo
echo -en "$gry Starting to configure"

for i in $(seq 1 3);do
    dot= echo -en "."
    echo -en $dot   
    sleep 1
done

echo

echo
echo -e "$gry -------------- Build my Vim --------------- "
echo -e "If Vim is installed but not configured, fix it!"
echo

# make directories in .vim containing bundle, colors, templates
myvim="$(cat result.log | grep vim | awk '{print $2}')"
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

# Download Vundle.vim
# Insert recommended Vundle settings in .vimrc
# copy original .vimrc first
vundle='git clone https://github.com/VundleVim/Vundle.vim.git ~/bin/mobuild/vimconf/bundle/Vundle.vim'
echo -e "$grn [ Cloning ] $gry" $vundle

#testing only [change path when ready]
cp vimconf/.vimrc vimconf/.vimrc_old

cat vimconf/vim_template vimconf/.vimrc > vimconf/tmprc

cp vimconf/tmprc vimconf/.vimrc

> ~/bin/mobuild/vimconf/tmprc

#echo -e "$dflt Done!"
#echo
#echo "Tip: Change .vim/ and .vimrc ownership from root to USER."
#echo 'Run sudo chown -R $USER: ~/.vim'

#cp -R vimconf/.vim ~/
#cp -R vimconf/.vimrc ~/ 

#if [ $? == 0 ]; then
#    echo -e "$dflt Done!"
#else
#    echo -e "$red Error!"
#fi
#echo
