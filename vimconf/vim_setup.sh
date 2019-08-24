#!/bin/bash 


#git clone https://github.com/VundleVim/Vundle.vim.git ~/practice/bundle/Vundle.vim

cp .vimrc .vimrc_old

cat vim_template .vimrc > tmprc
cp tmprc .vimrc

> tmprc
