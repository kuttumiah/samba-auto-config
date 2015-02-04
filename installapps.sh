#!/bin/bash

# /**
# * ================================================================================
# * This is solelydevelopeed to run on Arch Linux or any Arch based distributions.
# * This script will be used to install open-vm-tools and samba file server.
# * The file also configures open-vm-tools and set it to run on boot.
# * @author             Robaiatul Islam Shaon
# * @version            0.1
# * @created            02 February 2015 15:50
# * @last modified      Robaiatul Islam Shaon on 04 February 2015 15:43
# * @see                https://bitbucket.org/kuttumiah/odesk-job-florian
# * ================================================================================
# */

sudo pacman -Syy
sudo pacman -S open-vm-tools open-vm-tools-modules samba
echo "Installation of open-vm-tools and samba completed successfully!"

# This portion is for file sharing of open-vm-tools, currently not working
# sudo pacman -S dkms linux-headers
# aurget -S --deps --noedit open-vm-tools-dkms

# configuring for open-vm-tools
echo "Configuring open-vm-tools..."

sudo cat /proc/version | sudo tee -a /etc/arch-release > /dev/null
# sudo cat /proc/version > /etc/arch-release
sudo systemctl stop vmtoolsd.service
sudo sed -i.bak '/vmtoolsd/a KillSignal=SIGKILL' \
/usr/lib/systemd/system/vmtoolsd.service
sudo systemctl start vmtoolsd.service

echo "open-vm-tools configured successfully !"
echo "Please reboot to apply changes successfully !"
