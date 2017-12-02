#!/bin/bash

ISO="$1"
#NAME="$2"

if [[ $# < 1 ]]; then
  echo "USAGE: $0 [/full/path/to/rhel-server-7.4-x86_64-dvd.iso ]"
  exit 1
fi
#check_packer 
if [[ -z $(packer --version) ]]; then
  echo "Installing packer"
  wget https://releases.hashicorp.com/packer/1.1.2/packer_1.1.2_darwin_amd64.zip && \
  unzip packer_1.1.2_darwin_amd64.zip packer -d /usr/local/bin/ && rm packer*.zip
fi

#DISTRO=$(echo ${ISO} |awk -F'-' '{print $1}'|tr '[:upper:]' '[:lower:]')
echo "ISO ${ISO}"
#git clone https://github.com/opscode/bento.git && 
#cd bento
#mkdir -p iso/rhel && cd iso && ln -s $1 rhel/ && \
#packer build -only=virtualbox-iso -var mirror=file:///$(pwd) ../rhel/rhel-7.4-x86_64.json
