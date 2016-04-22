#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y -q update
apt-get -y -q install curl wget || true
apt-get -y -q install gnuplot-nox gdb || true
apt-get -y -q  --force-yes dist-upgrade
apt-get clean

# You can install anything you need here.
