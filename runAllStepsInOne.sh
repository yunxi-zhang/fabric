#!/bin/bash

# import common.sh
source ./common.sh

# The steps 1-3 will remove all docker iamges in a machine
# comment them out if this is not the right intention to do

# Step 1: stop all current docker containers including those not in this project
stepInfo "Step 1: Stop All Current Docker Containers Including Those Are Not In This Project"
docker stop $(docker ps -aq)
# Step 2: remove all docker containers
stepInfo "Step 2: Remove All Docker Containers"
docker rm -f $(docker ps -aq)
# Step 3: remove all docker images
stepInfo "Step 3: Remove All Docker Images"
docker rmi -f $(docker images -aq)
# Step 4: show docker images
stepInfo "Step 4: Show Docker Images"
docker images
# Step 5: remove all docker info
stepInfo "Step 5: Clean All Docker Info"
docker system prune --all --force --volumes 
# Step 6: remove all the files that will be generated in this project if they exist
stepInfo "Step 6: Remove All The Files That Will Be Generated In This Project If They Exist"
rm -rf bin channel-artifacts config crypto-config scripts
rm -rf webapp/identity/user/*/wallet/Admin@*
# Step 7: show these files do not exist
stepInfo "Step 7: Show That These Files Do Not Exist"
ls -al bin
ls -al channel-artifacts 
ls -al config
ls -al crypto-config
ls -al scripts

# Step 8: run all other shell files for this project
stepInfo "Step 8: Run All Other Shell Files In This Project"
# export this variable so the sub shell files can use it
export CHANNEL_PROFILE1=ChannelSeller
export CHANNEL_PROFILE2=ChannelBuyer
channelName1=channel-seller
channelName2=channel-buyer
stepInfo "The 1st channel name is: $channelName1" 
stepInfo "The 2nd channel name is: $channelName2" 
export CHANNEL_NAME1=$channelName1
export CHANNEL_NAME2=$channelName2
./stage1_downloadbin.sh
./stage2_generateKey.sh
./stage3_generateConfigTx.sh
figlet Start Setting Up Hyperledger Fabric Network
./stage4_runDockerCompose.sh

# Step 9: show all the running docker containers
stepInfo "Step 9: Show All The Running Docker Containers"
docker ps 

stepInfo "Sleeping for 5 seconds ..."
sleep 5
stepInfo "End of sleeping"
# stage 5 runs only after docker containers are running
./stage5_putChannelConfigTxToContainer.sh

# stage 6: install chaincode on peers 
./stage6_installAndInstantiateChaincode.sh
figlet Complete Setting Up Hyperledger Fabric Network

sleep 5
echo '----------------------------------------------------------------------------------------------------'


figlet Start Setting Up Web Servers
# stage 7: run all web servers
./stage7_runWebServers.sh
figlet Complete Setting Up Web Servers