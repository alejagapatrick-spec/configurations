#!/bin/bash

set -e

cd $HOME

mkdir -p ./bin

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  platform='Linux'
  sudo apt-get install \
    xsel \
    bc \
    tig \
    bmon \
    git \
    vim \
    tmux
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='Darwin'
  brew install \
    fpp \
    reattach-to-user-namespace \
    terminal-notifier \
    wget \
    youtube-dl \
    tig \
    bmon \
    git \
    vim \
    tmux
else
  echo "[ERROR] Unknown platform."
  exit 1
fi

CONFIG_DIR="$HOME/configurations"
if [ ! -d "$CONFIG_DIR" ]; then
  git clone https://github.com/weilonge/configurations.git $CONFIG_DIR
  git config --global core.excludesfile $CONFIG_DIR/git/gitignore_global
else
  echo "configurations checked."
fi

if [ ! -f ~/.tmux.conf ]; then
  ln -s $CONFIG_DIR/tmux.conf $HOME/.tmux.conf
else
  echo ".tmux.conf checked."
fi

if [ ! -d "$HOME/.vim" ]; then
  git clone https://github.com/weilonge/dotvim.git $HOME/.vim
  ln -s $HOME/.vim/vimrc $HOME/.vimrc
  git config --global core.editor vim
  vim +PlugUpgrade +PlugInstall +qa
else
  echo ".vim checked."
fi

if [ ! -f ~/.tigrc ]; then
  ln -s $CONFIG_DIR/tig/main.tigrc ~/.tigrc
else
  echo ".tigrc checked."
fi

TOOLS_DIR=$HOME/Projects/tools
mkdir -p ${TOOLS_DIR}

# powerline-shell
if [ ! -x "`which powerline-shell`" ]; then
  pip install powerline-shell
  ln -s $CONFIG_DIR/powerline-shell.json $HOME/.powerline-shell.json
else
  echo "powerline-shell checked."
fi

# powerline-fonts
if [ ! -d "${TOOLS_DIR}/powerline-fonts" ]; then
  git clone https://github.com/powerline/fonts.git ${TOOLS_DIR}/powerline-fonts --depth=1
  cd ${TOOLS_DIR}/powerline-fonts
  ./install.sh
  cd -
else
  echo "powerline-fonts checked."
fi

# Install NVM
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
else
  echo ".nvm checked."
fi

if [[ $platform == 'Linux' ]]; then
  if [ ! -x "`grep bash_source_me ~/.bashrc`" ]; then
    echo '
source ~/configurations/bash_source_me
' >> ~/.bashrc
  else
    echo "~/.bashrc checked."
  fi
elif [[ $platform == 'Darwin' ]]; then
  if [ ! -x "`grep bash_source_me ~/.bash_profile`" ]; then
    echo '
source ~/configurations/bash_source_me
test -f ~/.bashrc && source ~/.bashrc
' >> ~/.bash_profile
  else
    echo "~/.bash_profile checked."
  fi
fi

