#!/bin/bash


sleep 5

# Enable passwordless sudo for cumulus user
echo "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10_cumulus

# Create mew metpops user
adduser netops --disabled-password -gecos "Network Admin User ACcount"
adduser netops sudo
echo "netops:ticketmaster123!" | chpasswd

# Genereate ssh keys
ssh-keygen -f $HOME/.ssh/id_rsa -q -N ""

# Add a public key for the cumulus user
wget http://172.17.0.2/id_rsa.pub -o /dev/null -O - | cat >> /home/cumulus/.ssh/authorized_keys
chmod 700 -R /home/cumulus/.ssh
chown cumulus:cumulus -R /home/cumulus/.ssh

# License the switch
#cl-license -i http://oob-mgmt-server/`hostname`.lic

# Restart switchd for license to take effect
service switchd restart

# Set all ports on the device as admin up
for i in `ls /sys/class/net -1 | grep swp`; do  ip link set up $i; done;

# Grab the ptm file and restart ptm
wget http://172.17.0.2/topology.dot -O /etc/ptm.d/topology.dot
service ptmd restart


exit 0
#CUMULUS-AUTOPROVISIONING