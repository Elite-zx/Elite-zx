#!/bin/bash

#update
sudo apt update
sudo apt upgrade -y

# basic developer tool, such as gcc,g++,make
sudo apt install build-essential -y

#----------------------------------------zsh---------------------------------------- 
sudo apt install zsh -y

# zsh Powerlevel10k theme
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# colorls
sudo apt install ruby-full -y
sudo gem install colorls  -y

# bat
sudo apt install bat -y

# duf
apt install duf

#----- -----------------------------------vim---------------------------------------------
sudo apt install vim -y
# enable clipboard
sudo apt install vim-gtk3 -y

# ----------------------------------------fcitx5---------------------------------------------
# install fcitx5
sudo apt install fcitx5 \
fcitx5-chinese-addons \
fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 \
fcitx5-frontend-qt5 -y

# install dict
wget https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/0.2.4/zhwiki-20220416.dict  
mkdir -p ~/.local/share/fcitx5/pinyin/dictionaries/  
mv zhwiki-20220416.dict ~/.local/share/fcitx5/pinyin/dictionaries/

#-------------------------------------------shortcut tool----------------------------------------
# install flameshot
sudo apt install flameshot -y

#--------------------------------------------use dpkg tools------------------------------------
# dpkg --get-selections > selections.txt
sudo dpkg --set-selections < selections.txt
sudo apt-get dselect-upgrade
sudo apt-get dselect-upgrade

#-------------------------------------------Mac style UI----------------------------------------
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh

git clone https://github.com/vinceliuice/WhiteSur-icon-theme
cd  WhiteSur-icon-theme
./install.sh

sudo apt install chrome-gnome-shell -y
sudo apt install gnome-shell-extensions -y



