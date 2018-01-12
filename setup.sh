#!/bin/env bash

REPOS="rhel-7-server-optional-rpms rhel-7-server-rh-common-rpms \
rhel-7-server-optional-fastrack-rpms  rhel-7-server-ansible-2.4-rpms \
rhel-7-fast-datapath-rpms rhel-7-server-extras-rpms rhel-7-server-ose-3.6-rpms \
rhel-7-server-rpms"

SSH_KEYS="/vagrant/keys/*id_rsa"
PKGS="git wget tmux vim tree"

SSH_OPTIONS="ssh -A -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
#ALIAS="alias bastion='ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  jthopenshiftb.eastus.cloudapp.azure.com' "
#ALIAS2="alias honeywell='ssh -A -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  honeywell@40.112.212.69'"
#ALiAS3="alias honeywell-bastion='ssh -A -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  honeywell@hwlabspecb.westus.cloudapp.azure.com'"

ALIAS=("alias bastion='${SSH_OPTIONS}  jthopenshiftb.eastus.cloudapp.azure.com'" 
       "alias honeywell='${SSH_OPTIONS} honeywell@40.112.212.69'" 
       "alias honeywell-bastion='${SSH_OPTIONS} honeywell@lab-spec-westus-rgb.westus.cloudapp.azure.com'")

function pkgs {
  # Disable all first
  sudo subscription-manager repos --disable=*
  for repo in ${REPOS}; do
    echo ${repo}
    sudo subscription-manager repos --enable=${repo}
  done
#  sleep 10
  sudo  yum install -y  ${PKGS}

}

function setup_bashrc {
  if [[ $(grep -c ssh_auth_sock ~/.bashrc) < 1 ]]; then
  cat >> ~/.bashrc <<'EOF'
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l | grep "The agent has no identities" && ssh-add \${SSH_KEYS}
EOF
   mkdir ~/.ssh
fi


IFS=""
#for alias in ${ALIASES}; do
for a in ${ALIAS[*]}; do
  echo "Adding ALIAS ${a}"
  grep "${a}" ~/.bashrc || echo "${a}" >> ~/.bashrc
done

}

function setup_ssh {
  found=$(grep -cs "Host \*" ~/.ssh/config)
  if [[ $found < 1 ]]; then
  cat >> ~/.ssh/config <<EOF
Host *
   StrictHostKeyChecking=no
   UserKnownHostsFile=/dev/null
   LogLevel QUIET
EOF
  fi
}

function setup_tmux {
  cat > ~/.tmux.conf <<EOF
setw -g mode-mouse on
set -g mouse-select-pane on
set -g mouse-resize-pane on
set -g mouse-select-window on
EOF

}

function setup_vimrc {

  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  cd ~/.vim/bundle/ && git clone git://github.com/altercation/vim-colors-solarized.git

  cat  > ~/.vimrc  <<EOF
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
filetype plugin indent on

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'pearofducks/ansible-vim'

call vundle#end()

syntax on
au BufRead,BufNewFile *.y*ml set filetype=ansible
autocmd FileType yaml setlocal ai ts=2 sw=2 et


set number

set wrap
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
colorscheme solarized
EOF

}

pkgs
setup_bashrc
setup_ssh
setup_tmux
setup_vimrc
#
