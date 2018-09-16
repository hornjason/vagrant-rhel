#!/bin/env bash

REPOS="rhel-7-server-optional-rpms rhel-7-server-rh-common-rpms \
rhel-7-server-optional-fastrack-rpms  rhel-7-server-ansible-2.5-rpms \
rhel-7-fast-datapath-rpms rhel-7-server-extras-rpms rhel-7-server-ose-3.10-rpms \
rhel-7-server-rpms"

SSH_KEYS="/vagrant/keys/*id_rsa"
PKGS="git wget tmux screen vim bash-completion tree needs-restarting"

SSH_OPTIONS="ssh -A -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ALIAS=""

USERS="vagrant"

function pkgs {
  # Disable all first
  sudo subscription-manager repos --disable="*"
  for repo in ${REPOS}; do
    echo ${repo}
    sudo subscription-manager repos --enable=${repo}
  done
#  sleep 10
  sudo  yum install -y  ${PKGS}
  sudo yum autoremove -y epel-release

}

function setup_bashrc {
  if [[ $(grep -c ssh_auth_sock ${1}/.bashrc) < 1 ]]; then
  cat >> ${1}/.bashrc <<EOF
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval \`ssh-agent\`
  ln -sf "\${SSH_AUTH_SOCK}" ~/.ssh/ssh_auth_sock
  ssh-add -l | grep "The agent has no identities" && ssh-add ${SSH_KEYS}
fi
EOF
  fi


IFS=""
#for alias in ${ALIASES}; do
for a in ${ALIAS[*]}; do
  echo "Adding ALIAS ${a}"
  grep "${a}" ${1}/.bashrc || echo "${a}" >> ${1}/.bashrc
  chown -R ${2}:${2} ${1}/.bashrc
done

}

function setup_ssh {
  mkdir ${1}/.ssh
  chown -R ${2}:${2} ${1}/.ssh
  found=$(grep -cs "Host \*" ${1}/.ssh/config)
  if [[ $found < 1 ]]; then
  cat >> ${1}/.ssh/config <<EOF
Host \*
   StrictHostKeyChecking=no
   UserKnownHostsFile=/dev/null
EOF
  fi
}

function setup_tmux {
  cat > ${1}/.tmux.conf <<EOF
setw -g mode-mouse on
set -g mouse-select-pane on
set -g mouse-resize-pane on
set -g mouse-select-window on
EOF
  chown -R ${2}:${2} ${1}/.ssh

}

function setup_vimrc {
https://github.com/drm/jinja2-lint.git
  if [ ! -d "${1}/jinja2-lint" ] ; then
    git clone https://github.com/drm/jinja2-lint.git
    sudo cp "${1}/jinja2-lint/j2lint.py" /usr/local/bin/
  if [ ! -d "${1}/.vim/bundle/Vundle.vim" ] ; then
    git clone https://github.com/VundleVim/Vundle.vim.git ${1}/.vim/bundle/Vundle.vim
  fi

  if [ ! -d "${1}/.vim/bundle/ansible-vim" ] ; then
    cd ${1}/.vim/bundle/ && git clone https://github.com/pearofducks/ansible-vim.git
  fi
  chown -R ${2}:${2} ${1}/.vim

  cat  > ${1}/.vimrc  <<EOF

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
filetype plugin indent on

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'pearofducks/ansible-vim'

call vundle#end()

syntax on
au BufRead,BufNewFile *.y?ml set filetype=ansible
autocmd FileType yaml setlocal ai ts=2 sw=2 et


set number

set wrap
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set background=dark
EOF

}

function setup_sudo {
  cat > /etc/sudoers.d/${2} <<EOF
${2}        ALL=(ALL)       NOPASSWD: ALL
EOF
}

function setup_zsh {
   mkdir ${1}/.fonts/
   mkdir -p ${1}/.config/fontconfig/conf.d
   cd ${1}
   wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
   wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf  -O ${1}/.config/fontconfig/conf.d/10-powerline-symbols.conf
   mv PowerlineSymbols.otf ${1}/.fonts
   sed -i 's/^ZSH_THEME.*$/ZSH_THEME=agnoster/g' ${1}/.zshrc
}

###############
pkgs
for user in ${USERS};do
  home=/home/${user}
  useradd -m -U -G wheel,vagrant ${user}
  setup_bashrc ${home} ${user}
  setup_ssh ${home} ${user}
  setup_tmux ${home} ${user}
  setup_vimrc ${home} ${user}
  setup_sudo ${home} ${user}
  setup_zsh ${home} ${user}
done
###############
