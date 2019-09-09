#!/bin/bash

echo "Adding extra plugins"
IFS_OLD=$IFS
IFS=$'\n'
xplugn=$(cat vimconf/vimplugn.list)
count=11

for i in $xplugn; do
    sed -i "$count a $i" vimconf/.vimrc
done

IFS=$IFS_OLD

echo "Open vim and run :PluginInstall to properly install added Plugins."
