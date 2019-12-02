#!/bin/bash

echo
echo -en "$gry Starting to configure..."
echo
echo -e "$dflt ------------------------- Build my Vim -------------------------"
echo -e " If Vim is installed but not configured for using Vundle, fix it!"
echo

date=$(date +%y/%m/%d)
time=$(date +%H:%M:%S)

# Change this value to ~/.vim
#test_vim_dir=$HOME/gitz/mobuild/vimconf
test_vim_dir=$HOME/repo/mobuild/vimconf

grn="\e[32m"
dflt="\e[39m"
red="\e[91m"
gry="\e[90m"

# make directories in .vim containing bundle, colors, templates
# check if vim is installed
myvim="$(cat ../logs/result.log | grep vim | awk '{print $2}')"

# make directories in ~/.vim
if [ $myvim == '+' ]; then
    for i in $(jq -r '.vim.mkdir[]' ../config.json); do
        echo -en "$grn [ mkdir ] $dflt $test_vim_dir/$i..."
        mkdir -p $test_vim_dir/$i 2> error.log
        if [[ $? == 0 ]]; then
            echo -e "$grn Okay $dflt"
        fi
    done
fi

# download colorschemes
for i in $(jq -r '.vim.colorscheme[]' ../config.json); do
    file=$(echo $i | sed 's/\// /g' | awk '{print $NF}')
    echo -en "$grn [ Downloading ] $dflt $file..."
    curl -o $test_vim_dir/.vim/colors/$file $i >> error.log 2>&1
    if [[ $? == 0 ]]; then
        echo -e "$grn Okay $dflt"
    else
        echo -e "$red Error $dflt:Please see error.log!"
    fi
done

# Create templates (templates will be applied when starting particular file in
# vim). This will just simply copy the skeleton files from templates directory
# to your ~/.vim/templates directory. You can edit skeleton files to your
# likings.
#skeleton_list=$(jq -r '.vim.skeleton[]' ../config.json)

#for i in $(jq -r '.vim.skeleton[]' ../config.json); do
#    echo -e "$grn [ Copying ] $dflt $i"
#    cp templates/$i ~/.vim/templates
#done

# Download Vundle.vim if not installed else exit
# Insert recommended Vundle settings in .vimrc
# copy original .vimrc first

# [testing] don't forget to change isvundle value to ~/.vim/bundle/Vundle.vim
isvundle=$HOME/repo/mobuild/vimconf/.vim/bundle/Vundle.vim
isvundleconf=$(cat $HOME/repo/mobuild/vimconf/.vimrc | grep -o 'VundleVim/Vundle.vim')

function setup_vundle {
    echo -en "$grn [ Configuring Vundle ]$dflt"
    FS_OLD=$IFS
    IFS=$'\n'

    cp .vimrc .vimrc_old

    cat vim_template .vimrc > tmprc
    cp tmprc .vimrc
    true > tmprc
    IFS=$IFS_OLD
    echo -e "...$grn Done $dflt"
}

if [ ! -e $isvundle ]; then
    echo -en "$grn [ Cloning ] $dflt"
    myvundle=$(jq -r '.vim.vundle[]' ../config.json)
    git clone $myvundle $HOME/repo/mobuild/vimconf/.vim/bundle/Vundle.vim
    setup_vundle
else
    echo " Vundle.vim is already installed in $isvundle"
    echo -en " Checking if it's configured to use Vundle..."
    if [[ $isvundleconf != 'VundleVim/Vundle.vim' ]]; then
        echo
        setup_vundle
    else
        echo -e "$grn Okay $dflt"
    fi
fi

echo
echo -e "$dflt Your original .vimrc was saved as .vimrc_old"
echo
echo " Recommend: Change ~/.vim and ~/.vimrc ownership from root to USER."
echo ' Run sudo chown -R $USER: ~/.vim ~/.vimrc'

echo
echo " Updated: $date at $time"

