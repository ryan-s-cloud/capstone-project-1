#!/bin/bash

set -x

# Create temp folder
WORK_DIR=/tmp/etcd
[ -d ${WORK_DIR} ] || mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

# Get the latest from the releases folder
curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest |\
  grep browser_download_url |\
  grep linux-amd64 |\
  cut -d '"' -f 4 | wget -qi -

# Extract the archive
tar xvf *.tar.gz

# Install in /usr/local/bin
cd etcd-*/
sudo mv etcd* /usr/local/bin/

# Cleanup
cd ..
rm -rf *.tar.gz etcd-*/
