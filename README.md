# mobuild

  The purpose of this project is to build and configure your machine into your personal needs. The main script will work if you are using "apt" as your package manager. 

# How it works?

  The idea is to check if wanted packages are installed to my machine. If not, then install it. The program will output a result letting me know what is installed or what is not installed. The program also has the ability to configure my .vimrc file, this includes installing Vudle.vim - a vim plugin manager, configuring Vundle.vim within .vimrc, and downloading my favorite vim colorshemes.

# Prerequisites

  * Linux OS
    * Ubuntu 18.04 or higher.
    * apt or apt-get
    * dpkg
    * jq

# Installing
```
cd to /path/you/want/mobuild/in/
git clone https://github.com/motet13/mobuild.git
```
### After cloning
  Now that mobuild has been cloned. Run mobuild.sh located in mobuild directory. Running mobuild.sh will let you know wether a package listed in mylist.txt is installed or not. You can edit mylist.txt to keep track on your packages.

If mobuild.sh is not executable, run
```
chmod +x mobuild.sh
```
then
```
sudo ./mobuild.sh
```
You can choose wether you want to install missing packages or not.

## Configuring Vim to use Vundle as plugin manager

#### You can also visit
* [Vundle](http://github.com/VundleVim/Vundle.Vim) - the actual page for installing Vundle

## Screenshot

![screentshot](images/Screenshot%202019-08-25%20at%2010.49.20%20AM.png)

#### Built Year 2019
