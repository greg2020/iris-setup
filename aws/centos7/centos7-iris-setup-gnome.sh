#!/bin/bash -xe
#
# AWS user data script for setting up Iris BHS on Centos7
#

# Record start time stamp
timestamp=$(date)
echo "User Data Script Start at: ${timestamp}"

echo "Setup Script Variables"
USERNAME=vncgui1
USER_PASSWORD=changeit

usage ()
{
    echo "Usage: setup-centos.sh -p user_password [-u]"
    echo "  options:"
    echo "      -p required     Password for the visallo user account you'll login using"
}

echo "PARSING SCRIPT ARGUMENTS"
while getopts "p:i" opt; do
  case $opt in
    p)
      USER_PASSWORD=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
  esac
done

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

echo "Adding Iris GUI User Account"
adduser $USERNAME
usermod -aG wheel $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd

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

echo "Setting PATHs"
echo 'export JAVA_HOME=$(dirname $(dirname $(readlink /etc/alternatives/javac)))' >> "/home/$USERNAME/.bash_profile"
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "/home/$USERNAME/.bash_profile"

echo "Installing GNOME Desktop"
yum -y groups install "GNOME Desktop"

echo "Installing XRDP"
yum -y install xrdp tigervnc-server
echo "X-GNOME-Autostart-enabled=false" | tee -a /etc/xdg/autostart/gnome-software-service.desktop
systemctl start xrdp.service
systemctl enable xrdp.service
