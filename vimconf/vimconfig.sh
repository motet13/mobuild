echo
echo -en "$gry Starting to configure..."
echo
echo -e "$dflt ------------------------- Build my Vim -------------------------"
echo -e " If Vim is installed but not configured for using Vundle, fix it!"
echo

# Change this value to ~/.vim
test_vim_dir=$HOME/gitz/mobuild/vimconf

grn="\e[32m"
dflt="\e[39m"
red="\e[91m"
gry="\e[90m"

# make directories in .vim containing bundle, colors, templates
# check if vim is installed
myvim="$(cat ../logs/result.log | grep vim | awk '{print $2}')"

# make directories in ~/.vim
dir_list=$(jq -r '.vim.mkdir[]' ../config.json)

if [ $myvim == '+' ]; then
    for i in $dir_list; do
        echo -en "$grn [ mkdir ] $dflt $test_vim_dir/$i..."
# This works just uncomment it when ready for production
#        mkdir -p $test_vim_dir/$i 2> error.log
        if [[ $? == 0 ]]; then
            echo -e "$grn Okay $dflt"
        fi
    done
fi

# download colorschemes
colorscheme_list=$(jq -r '.vim.colorscheme[]' ../config.json)

for i in $colorscheme_list; do
    file=$(echo $i | sed 's/\// /g' | awk '{print $NF}')
    echo -en "$grn [ Downloading ] $dflt $file..."
# This works just uncomment it when ready for production
    curl -o $test_vim_dir/colors/$file $i >> error.log 2>&1
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
skeleton_list=$(jq -r '.vim.skeleton[]' ../config.json)

for i in $skeleton_list; do
    echo -e "$grn [ Copying ] $gry $i"
#    cp templates/$i ~/.vim/templates
done

# Download Vundle.vim if not installed else exit
# Insert recommended Vundle settings in .vimrc
# copy original .vimrc first

# [testing] don't forget to change isvundle value to ~/.vim/bundle/Vundle.vim
isvundle=~/bin/mobuild/vimconf/bundle/Vundle.vim
isvundleconf=$(cat ~/.vimrc | grep -o 'VundleVim/Vundle.vim')

if [ -e $isvundle ]; then
    echo " Vundle.vim is already installed in $isvundle"
    echo -en " Checking if it's configured to use Vundle..."
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

echo -e "$dflt Your original .vimrc was saved as .vimrc_old"
echo
echo " Recommend: Change ~/.vim and ~/.vimrc ownership from root to USER."
echo ' Run sudo chown -R $USER: ~/.vim ~/.vimrc'


#if [ $? == 0 ]; then
#    echo -e "$dflt Done!"
#else
#    echo -e "$red Error!"
#fi
#echo
