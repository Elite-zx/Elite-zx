#!/bin/bash

#update
sudo apt update
sudo apt upgrade -y

#----------------------------------------basic develop tools-----------------------------------
# g++,gcc,make...
sudo apt install build-essential -y
# git
sudo apt install git -y
# curl
sudo apt install curl -y
# cmake
sudo apt install cmake -y
# libtool: manage shared library
sudo apt install libtool -y

#----------------------------------------zsh---------------------------------------- 
sudo apt install zsh -y

# on my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh plugin
# autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Effective tools in terminal emulator
# colorls
sudo apt install ruby-full -y
sudo gem install colorls  -y

# bat
sudo apt install bat -y
ln -s /usr/bin/batcat  /usr/bin/bat

# duf
sudo apt install duf -y

# screenfetch
sudo apt install screenfetch -y

# monaco-nerd-fonts
git clone https://github.com/Karmenzind/monaco-nerd-fonts
cp -r monaco-nerd-fonts/fonts/ /usr/share/fonts/monaco-nerd-fonts
cp -r monaco-nerd-fonts/fonts/ ~/.local/share/fonts


#----- -----------------------------------vim---------------------------------------------
sudo apt install vim -y
# enable clipboard
sudo apt install vim-gtk3 -y

# configuration
# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# for vim plugin
# solve Python.h: No such file or directory
sudo apt-get install python3-dev -y

# nodejs (version >= 14.14)
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E zsh -
sudo apt-get install -y nodejs
sudo dpkg -i --force-overwrite /var/cache/apt/archives/nodejs_14.21.3-deb-1nodesource1_amd64.deb
sudo apt -f install
sudo apt update
sudo apt dist-upgrade

# clangd for code completion and format
sudo apt install clangd -y
sudo apt install clang-format -y

# ctags
sudo apt-get install exuberant-ctags -y

#-------------------------------------------shortcut tool----------------------------------------
# install flameshot
sudo apt install flameshot -y

#--------------------------------------------use dpkg tools------------------------------------
# dpkg --get-selections > selections.txt
sudo dpkg --set-selections < selections.txt -y
sudo apt-get dselect-upgrade

#-------------------------------------------Mac style UI----------------------------------------
sudo apt install gnome-tweaks
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh

git clone https://github.com/vinceliuice/WhiteSur-icon-theme
cd  WhiteSur-icon-theme
./install.sh

sudo apt install chrome-gnome-shell -y
sudo apt install gnome-shell-extensions -y

#--------------------------------------------------logitech keys----------------------------------------
sudo apt-get install xbindkeys xautomation -y
xbindkeys --defaults > $HOME/.xbindkeysrc

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
# fcitx5 theme
sudo apt install fcitx5-material-color -y

