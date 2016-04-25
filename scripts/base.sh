#!/bin/bash

# update source list
cat <<EOF > /etc/apt/sources.list
deb http://hu.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
# deb-src http://hu.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse

deb http://hu.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
# deb-src http://hu.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse

deb http://hu.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src http://hu.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu xenial-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu xenial-security main restricted universe multiverse

# deb http://hu.archive.ubuntu.com/ubuntu/ xenial-proposed multiverse main restricted universe
# deb-src http://hu.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse
EOF

# Update the box
apt-get -y -q update
apt-get -y -q install facter linux-headers-$(uname -r) build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev curl unzip biosdevname

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
# and revert to plain old network interface naming
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US net.ifnames=0 biosdevname=0"
EOF
update-grub

# and create interfaces extension for eth0/eth1:
cat <<EOF >> /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet manual
EOF

# remove the new/strange eth iface names
sed -i.bak '/.*enp.*/d' /etc/network/interfaces

# sudo users
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo  ALL=(ALL:ALL) ALL/%sudo  ALL=NOPASSWD:ALL/g' /etc/sudoers

# vagrant user
echo "vagrant ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
echo "Defaults:vagrant !requiretty" | tee -a /etc/sudoers

