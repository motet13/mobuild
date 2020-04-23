#!/bin/bash 

IFS_OLD=$IFS
IFS=$'\n'
#git clone https://github.com/VundleVim/Vundle.vim.git ~/practice/bundle/Vundle.vim

cp .vimrc .vimrc_old

cat vim_template .vimrc > tmprc
cp tmprc .vimrc

true > tmprc

vimplugn=$(cat vimplugn.list)
count=12
for i in $vimplugn; do
    sed "$count i $i" .vimrc > .vimrc
    count=`expr $count + 1`
done

#sed "12 i $vimplugn" .vimrc
#echo $vimplugn
IFS=$IFS_OLD
