#!/usr/bin/env bash
#
# AWS user data script for setting up Iris BHS on Centos7
#
echo "SETTING UP SCRIPT VARIABLES"
JAVA_VERSION=8u111-b14
USERNAME=centos

cd /opt

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


echo "Updating Yum Packages"
yum -y update
yum install -y epel-release
yum install -y redhat-lsb-core
yum install -y initscripts
yum install -y python-pip
yum install -y monit
yum install -y wget
yum install -y java-1.8*
yum install -y unzip
yum install -y mariadb-server
yum install -y mariadb
yum install -y nfs-utils
yum install -y glibc
yum install -y libgcc
yum install -y libgomp
yum install -y libstdc++
yum install -y lighttpd
yum install -y bzip2
yum install -y git


echo "Configure Monit to start at boot"
systemctl enable monit
systemctl start monit

echo "Configure MariaDB to start at boot"
systemctl enable mariadb
systemctl start mariadb


echo "INSTALLING JAVA/JDK"
cd /opt
curl -H 'Cookie: oraclelicense=accept-securebackup-cookie' -f -s -L http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}/jdk-$(echo ${JAVA_VERSION} | sed -e 's/-.*//')-linux-x64.tar.gz | tar -xzf -
ln -s $(echo ${JAVA_VERSION} | sed -e 's/\(.*\)u\(.*\)-\(.*\)/jdk1.\1.0_\2/') jdk
echo 'export _JAVA_OPTIONS=-Djava.net.preferIPv4Stack=true' >> "/home/$USERNAME/.bash_profile"
echo 'export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8' >> "/home/$USERNAME/.bash_profile"
echo 'export JAVA_HOME=/opt/jdk' >> "/home/$USERNAME/.bash_profile"


echo "SETTING PATH"
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "/home/$USERNAME/.bash_profile"

echo "INSTALLING THE GNOME DESKTOP"
yum -y groups install "GNOME Desktop"

echo "INSTALLING XRDP"
yum -y install xrdp tigervnc-server
echo "X-GNOME-Autostart-enabled=false" | tee -a /etc/xdg/autostart/gnome-software-service.desktop
systemctl start xrdp.service
systemctl enable xrdp.service
