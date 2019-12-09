#!/bin/bash

echo
echo -en "$gry Starting to configure..."
echo
echo -e "$dflt ------------------------- Build my Vim -------------------------"
echo -e " If Vim is installed but not configured for using Vundle, fix it!"
echo

date=$(date +%y/%m/%d)
time=$(date +%H:%M:%S)

# Configuration file for vim
vim_json=../config.json

# Change this value to ~/.vim
#real_vim_dir=$HOME/gitz/mobuild/vimconf
real_vim_dir=$HOME/repo/mobuild/vimconf
real_vim_dir=$HOME/

grn="\e[32m"
dflt="\e[39m"
red="\e[91m"
gry="\e[90m"

# make directories in .vim containing bundle, colors, templates
# check if vim is installed
myvim="$(cat ../logs/result.log | grep vim | awk '{print $2}')"

# make directories in ~/.vim
if [ $myvim == '+' ]; then
    for i in $(jq -r '.vim.mkdir[]' $vim_json); do
        echo -en "$grn [ mkdir ]$dflt $real_vim_dir/$i..."
        mkdir -p $real_vim_dir/$i 2> error.log
        if [[ $? == 0 ]]; then
            echo -e "$grn Okay $dflt"
        fi
    done
fi

# Check if .vimrc file exist
echo -en "$grn [ Vimrc File ] $dflt"
if [ -e $vimrc ]
then
    echo -e "$grn... Okay $dflt"
else
    echo -e " making .vimrc file..."
    touch $HOME/.vimrc
fi

# download colorschemes
for i in $(jq -r '.vim.colorscheme[]' $vim_json); do
    file=$(echo $i | sed 's/\// /g' | awk '{print $NF}')
    if [ ! -e $real_vim_dir/.vim/colors/$file ]; then
        echo -en "$grn [ Downloading ] $dflt $file..."
        curl -o $real_vim_dir/.vim/colors/$file $i >> error.log 2>&1
        if [[ $? == 0 ]]; then
            echo -e "$grn Okay $dflt"
        else
            echo -e "$red Error $dflt:Please see error.log!"
        fi
    else
        echo -e "$grn [ Colorscheme ]$dflt $file...$grn Already Exists $dflt"
    fi
done

# Create templates (templates will be applied when starting particular file in
# vim). This will just simply copy the skeleton files from templates directory
# to your ~/.vim/templates directory. You can edit skeleton files to your
# likings.
#skeleton_list=$(jq -r '.vim.skeleton[]' $vim_json)

#for i in $(jq -r '.vim.skeleton[]' $vim_json); do
#    echo -e "$grn [ Copying ] $dflt $i"
#    cp templates/$i ~/.vim/templates
#done

# Download Vundle.vim if not installed else exit
# Insert recommended Vundle settings in .vimrc
# copy original .vimrc first

# [testing] don't forget to change isvundle value to ~/.vim/bundle/Vundle.vim
vimrc=$HOME/.vimrc
isvundle=$HOME/.vim/bundle/Vundle.vim
# isvundle=$HOME/gitz/mobuild/vimconf/.vim/bundle/Vundle.vim
# isvundleconf=$(cat $HOME/gitz/mobuild/vimconf/.vimrc | grep -o 'VundleVim/Vundle.vim')
isvundleconf=$(cat $vimrc | grep -o 'VundleVim/Vundle.vim')

function setup_vundle {
    echo -en "$grn [ Vundle ]$dflt Configuring..."
    FS_OLD=$IFS
    IFS=$'\n'

    cp $vimrc $HOME/.vimrc_old

    cat vim_template $vimrc > tmprc
    cp tmprc $vimrc
    true > tmprc
    IFS=$IFS_OLD
    echo -e "$grn Done $dflt"
}

echo -en "$grn [ Vundle ]$dflt Cheking if vundle is installed..."
if [ ! -e $isvundle ]; then
    echo -e " Installing Vundle"
    echo -en "$grn [ Cloning ] $dflt"
    myvundle=$(jq -r '.vim.vundle[]' $vim_json)
    echo -en "$myvundle..."
    git clone $myvundle $HOME/.vim/bundle/Vundle.vim >> error.log 2>&1
    # git clone $myvundle $HOME/gitz/mobuild/vimconf/.vim/bundle/Vundle.vim >> error.log 2>&1
    if [[ $? == 0 ]]; then
        echo -e "$grn Okay $dflt"
    fi
    setup_vundle
else
    echo -e "$grn Installed $dflt"
    echo -en "$grn [ Vundle ]$dflt is it configured..."
    if [[ $isvundleconf != 'VundleVim/Vundle.vim' ]]; then
        echo -e "$red No $dflt"
        setup_vundle
    else
        echo -e "$grn Yes $dflt"
    fi
fi

# Add Extra plugins after configuring Vundle for vim
IFS_OLD=$IFS
IFS=$'\n'
count=11

for i in $(jq -r '.vim.plugins[]' $vim_json)
do
    echo -en "$grn [ Plugins ]$dflt"
    if grep -q $i $vimrc
    then
        echo -e " $i...$grn Okay $dflt"
    else
        echo -e " Inserting $i..."
        sed -i "$count a Plugin '$i'" $vimrc
    fi
done

echo
echo " Open vim and run :PluginInstall to properly install added Plugins."

IFS=$IFS_OLD

echo
echo -e "$dflt Your original .vimrc was saved as .vimrc_old"
echo
echo " Recommend: Change ~/.vim and ~/.vimrc ownership from root to USER."
echo ' Run sudo chown -R $USER: ~/.vim ~/.vimrc'

echo
echo " Last ran: $date at $time"

