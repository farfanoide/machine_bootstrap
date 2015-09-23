#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# Description
# -----------
#
#  Bootstrap script to setup my machine from scratch.
#  This script should have as little dependencies as possible, namely:
#     - ssh key-pair.
#
# ------------------------------------------------------------------------------
# Author
# -------
#
#  * Farfanoide (https://github.com/farfanoide)
#
# ------------------------------------------------------------------------------
set -e

SRC_DIR="$HOME/Develop/src"
ANSIBLE_DIR="$SRC_DIR/temp/ansible"
ANSIBLE_PLAYBOOK_DIR="$SRC_DIR/ansible"


[ ! -d $SRC_DIR ] && mkdir -p $SRC_DIR

# Download and install Command Line Tools
if test $(xcode-select -p > /dev/null); then
  echo "[INFO] ----- [ Installing Command Line Tools ] -------------------------------"
  xcode-select --install
  echo "[ERROR] ---- [ Run the sript again once CLT are installed ] -----------------"
  exit 1
fi

# Download and install Homebrew
if [ ! -x /usr/local/bin/brew ]; then
  echo "[INFO] ----- [ Installing Homebrew ] -----------------------------------------"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Modify the PATH
export PATH=/usr/local/bin:$PATH

# Download and install Ansible
if [ ! -x /usr/local/bin/ansible ]; then
  echo "[INFO] -----[ Installing Ansible ]--------------------------------------------"
  brew install ansible
fi


if [[ "$(ansible --version | head -1 | cut -d' ' -f2 | cut -d '.' -f1)" = "1" ]]; then
  # Ansible 1.9.x was installed, we need version 2.x to use osx_defaults module

  echo "[INFO] ----- [ Ansible v1 found, installing version 2 from Github ] ---------"
  #[[ "$(type chpwd > /dev/null)" =~ 'function' ]] && unfunction chpwd

  if [ ! -d $ANSIBLE_DIR/.git ]; then
    mkdir -p $ANSIBLE_DIR
    git clone -b devel https://github.com/ansible/ansible $ANSIBLE_DIR
    (cd $ANSIBLE_DIR && git submodule update --init --recursive)
    sudo easy_install pip
    sudo pip install paramiko PyYAML Jinja2 httplib2 six
  fi

  source $ANSIBLE_DIR/hacking/env-setup > /dev/null
fi

# Check for ssh keys
if [ ! -e $HOME/.ssh/id_rsa -o  ! -e $HOME/.ssh/id_rsa.pub ]; then
  echo "[ERROR] -----[ SSH key pair not found ]---------------------------------------"
  exit 1
fi

if [ ! -d $ANSIBLE_PLAYBOOK_DIR ]; then
  echo "[INFO] -----[ Downloading Ansible Playbooks ]---------------------------------"
  git clone git@github.com:farfanoide/machine_bootstrap.git $ANSIBLE_PLAYBOOK_DIR
  (cd $ANSIBLE_PLAYBOOK_DIR && git submodule update --init --recursive)
fi

ansible-playbook $ANSIBLE_PLAYBOOK_DIR/main.yml
