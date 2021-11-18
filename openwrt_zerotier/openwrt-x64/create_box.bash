#! /bin/bash
#
# create_box.bash
# Copyright (C) 2020-2021 Óscar García Amor <ogarcia@connectical.com>
#
# Distributed under terms of the GNU GPLv3 license.
#

VERSION="21.02.1"
TARGET="64"
ARCH="64"

URL="https://downloads.openwrt.org/releases/${VERSION}/targets/x86/${TARGET}/openwrt-${VERSION}-x86-${TARGET}-generic-ext4-combined.img.gz"
VDI="openwrt-${VERSION}-${ARCH}.vdi"
VMNAME="openwrt-${VERSION}-${ARCH}"

# Create a temporally workdir
WORKDIR="$(mktemp -d)"

# Download image source
curl -s "${URL}" -o "${WORKDIR}/openwrt.img.gz"

# Calculate SIZE of image dynamically
SIZE=$(cat "${WORKDIR}/openwrt.img.gz" | gunzip | wc -c)

# Create box
cat "${WORKDIR}/openwrt.img.gz" | gunzip | \
  VBoxManage convertfromraw --format VDI stdin ${VDI} ${SIZE}
VBoxManage createvm --name ${VMNAME} --register && \
VBoxManage modifyvm ${VMNAME} \
  --description "A VM to build an OpenWRT Vagrant box." \
  --ostype "Linux26" \
  --memory "512" \
  --cpus "1" \
  --nic1 "nat" \
  --cableconnected1 "on" \
  --natdnshostresolver1 "on" \
  --natpf1 "ssh,tcp,,2222,,22" \
  --natpf1 "luci,tcp,,8080,,80" \
  --nic2 "nat" \
  --cableconnected2 "on" \
  --natdnshostresolver2 "on" \
  --nic3 "nat" \
  --cableconnected3 "on" \
  --natdnshostresolver3 "on" \
  --uart1 "0x3F8" "4" \
  --uartmode1 server "$(pwd)/serial" && \
VBoxManage storagectl ${VMNAME} \
  --name "SATA Controller" \
  --add "sata" \
  --portcount "4" \
  --hostiocache "on" \
  --bootable "on" && \
VBoxManage storageattach ${VMNAME} \
  --storagectl "SATA Controller" \
  --port "1" \
  --type "hdd" \
  --nonrotational "on" \
  --medium ${VDI}

# Start the VM
VBoxManage startvm ${VMNAME} --type "headless"

# Use the serial port to make the image compatible with Vagrant
echo "Sleeping for 30s to let the image boot."
timeout 30 nc -U serial

echo "Sending commands."
echo -e '\n\n\nsed -i 's/eth1/eth2/g' /etc/config/network && \
  sed -i 's/eth0/eth1/g' /etc/config/network && \
  uci set network.management=interface && \
  uci set network.management.ifname=eth0 && \
  uci set network.management.proto=dhcp && \
  uci set network.management.defaultroute=0 && \
  uci add firewall zone && \
  uci set firewall.@zone[-1].name=management && \
  uci add_list firewall.@zone[-1].network=management && \
  uci set firewall.@zone[-1].input=ACCEPT && \
  uci set firewall.@zone[-1].output=ACCEPT && \
  uci set firewall.@zone[-1].forward=ACCEPT && \
  uci commit && \
  echo poweroff > /sbin/shutdown && \
  chmod a+x /sbin/shutdown && \
  echo -e "root\nroot" | passwd && \
  poweroff' | nc -U serial

echo "Waiting for poweroff."
until $(VBoxManage showvminfo --machinereadable ${VMNAME} | \
  grep -q ^VMState=.poweroff.); do
  sleep 1
done

# Disconnect the uart port
VBoxManage modifyvm ${VMNAME} --uartmode1 disconnected

# Export as Vagrant Box and Delete the VM
vagrant package --base ${VMNAME} --output "${VMNAME}.box" && \
  VBoxManage unregistervm ${VMNAME} --delete

# Delete workdir
rm -rf ${WORKDIR}
