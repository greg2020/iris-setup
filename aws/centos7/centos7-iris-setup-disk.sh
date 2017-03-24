#!/usr/bin/env bash
#
# AWS user data script for setting up Iris BHS on Centos7
#

# Record start time stamp
timestamp=$(date)
echo "User Data Script Start at: ${timestamp}"

echo "Setting Up Iris DB Volume"
DEVICE=$(lsblk | tail -1 | tr -s ' ' | cut -d ' ' -f 1)
if [ "$(file -s /dev/$DEVICE)" = "/dev/${DEVICE}: data" ]
then
    mkfs -t ext4 /dev/$DEVICE
    mkdir /db
    mount /dev/$DEVICE /db
    cp /etc/fstab /etc/fstab.orig
    UUID=$(ls -al /dev/disk/by-uuid/ | grep $DEVICE | tr -s ' ' | cut -d ' ' -f 9)
    echo -e "UUID=${UUID} /db\text4\tdefaults,nofail\t0 2" >> /etc/fstab
fi

echo "Done."