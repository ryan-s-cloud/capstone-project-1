#!/bin/bash

try_install() {
  DEBIAN_FRONTEND=noninteractive
  dpkg -s "$@" > /dev/null 2>&1 ||\
  sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" \
               -o Dpkg::Options::="--force-confold" install "$@"
}

set -x

try_install build-essential

gcc -o memory-stress memory-stress.c
