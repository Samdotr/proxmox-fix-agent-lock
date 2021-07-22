#!/bin/bash

# This script will fix the wait_for_agent_lock error state that can occur in a Proxmox HA Cluster
# In the default configuration, this script will assume you have the minimum number of nodes (3)
# but you can adapt this to run on larger node configurations

# For this fix to work effectively, you need to define IP addresses of the MASTER_NODE and other nodes
# because the script will run the required commands on non-MASTER_NODE nodes first
# Go to the Datacenter > HA page to see which node is the MASTER_NODE

echo "This script will execute commands on your Proxmox cluster nodes to fix the wait_for_agent_lock error"
echo "It is recommended to run this script as the root user on one of your cluster nodes for ease of use"
echo "To start with, we need to know the IP addresses of the nodes in your cluster"

echo "Please enter the IP address of the node listed as the MASTER node in the Datacenter HA page"
read MASTER_NODE
echo "Master node IP address is $MASTER_NODE"

echo "Now you will be asked for the IP addresses of the other non master nodes. The order of these does not matter"

echo "Please enter the IP address of one of the other non master nodes"
read OTHER_NODE_1
echo "Master node IP address is $OTHER_NODE_1"

echo "Please enter the IP address of one of the other non master nodes"
read OTHER_NODE_2
echo "Master node IP address is $OTHER_NODE_2"

# Stops the HA service on the second non-MASTER_NODE node
echo "Stopping HA service on $OTHER_NODE_2"
ssh root@$OTHER_NODE_2 'systemctl stop pve-ha-crm.service'

# Stops the HA service on the first non-MASTER_NODE node
echo "Stopping HA service on $OTHER_NODE_1"
ssh root@$OTHER_NODE_1 'systemctl stop pve-ha-crm.service'

# Stops the HA service on the MASTER_NODE node
echo "Stopping HA service on $MASTER_NODE"
ssh root@$MASTER_NODE 'systemctl stop pve-ha-crm.service'

# Removes the HA manager status file on the MASTER_NODE node
echo "Removing the HA manager status file on $MASTER_NODE"
ssh root@$MASTER_NODE 'rm -f /etc/pve/ha/manager_status'

# Starts the HA service on the second non-MASTER_NODE node
echo "Starting HA service on $OTHER_NODE_2"
ssh root@$OTHER_NODE_2 'systemctl start pve-ha-crm.service'

# Starts the HA service on the first non-MASTER_NODE node
echo "Starting HA service on $OTHER_NODE_1"
ssh root@$OTHER_NODE_1 'systemctl start pve-ha-crm.service'

# Starts the HA service on the MASTER_NODE node
echo "Starting HA service on $MASTER_NODE"
ssh root@$MASTER_NODE 'systemctl start pve-ha-crm.service'

echo "Task finished, please now recheck the HA page to confirm"
