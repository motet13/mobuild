#!/bin/bash

echo "Adding extra plugins"
IFS_OLD=$IFS
IFS=$'\n'
#xplugn=$(cat vimconf/vimplugn.list)
count=11

# for i in $xplugn; do
#     sed -i "$count a $i" vimconf/.vimrc
# done

# echo "Open vim and run :PluginInstall to properly install added Plugins."
for i in $(jq -r '.vim.plugins[]' config.json)
do
    sed -i "$count a Plugin '$i'" vimconf/.vimrc
done

IFS=$IFS_OLD


# Updated 11/30/19
