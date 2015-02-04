#!/bin/bash

# /**
# * ================================================================================
# * This is solely developeed to run on Arch Linux or any Arch based distributions.
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

# configuring open-vm-tools
echo "Configuring open-vm-tools..."
sudo systemctl stop vmtoolsd.service
cat /proc/version | sudo tee /etc/arch-release > /dev/null
sudo sed -i.bak '/vmtoolsd/a KillSignal=SIGKILL' \
/usr/lib/systemd/system/vmtoolsd.service
sudo systemctl start vmtoolsd.service
echo "open-vm-tools configured successfully !"
# end configuring open-vm-tools

# configuring samba file server
echo "Configuring samba..."
sudo systemctl enable smbd.service
sudo systemctl enable nmbd.service
echo "samba file server configured successfully !"
# end configuring samba file server

echo "Please reboot to apply changes successfully !"
