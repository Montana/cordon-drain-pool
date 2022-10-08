#!/bin/bash -e

display_usage() {
  echo "Cordons and drains a nodepool"
  echo -e "\nUsage:\n ./cordon-drain-pool [nodepool-name] "
  echo -e " ./cordon-drain-pool pool-1 \n"
}

if [  $# -le 1 ]
then
  display_usage
  exit 1
fi

NODE_POOL=$1
NODES=$(kubectl get nodes -l cloud.google.com/gke-nodepool="${NODE_POOL}" -o=name)

echo "WARNING: The following script will cordon and then drain nodes from ${NODE_POOL}"
echo "The following nodes will be cordoned & drained"
echo ""
for node in $NODES; do
  echo "$node"
done

echo ""
while true; do
    read -p "Do you wish to continue? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "First cordoning nodes"
for node in $NODES; do
  kubectl cordon "${node}";
done

echo "Cordoning finished"
echo "Waiting for 2 seconds to allow CLI output to update"
sleep 2
echo "Draining nodes"
for node in $NODES; do
  kubectl drain "${node}" --force=true --delete-local-data=true --ignore-daemonsets;
done
