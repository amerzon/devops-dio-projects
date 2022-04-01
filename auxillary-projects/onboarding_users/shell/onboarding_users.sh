#!/bin/bash

# Scriptname: onboarding_users.sh
# Purpose: Create accounts for new users with ssh only login, secondary group membership as 'developer'

# Variables
names_file='./names.csv'
primary_group='users'
secondary_group='developers'
user_shell='/usr/bin/bash'
script_name=`basename $0`
log_dir="/var/log/$script_name"
datestring=`date +%F_`
log_file="$log_dir/Ouput_$script_name_$datestring.log"

function logger() {
        TS=`date +"%F %T"`
        if [[ $1 == "I" ]]; then
                MsgType="INFO"
        elif [[ $1 == "E" ]]; then
                MsgType="ERROR"
        elif [[ $1 == "D" ]]; then
                MsgType="DEBUG"
        fi
        echo -e "$TS\t$MsgType:$2" >> $log_file
}

# Begin
logger I ">>> Starting $script_name Execution"

# Run as root only check
if [ `id -u` -ne 0 ]; then
        logger E "This script can only be run by the root user!"
        logger E "Terminating script due to inappropriate user privilages."
        exit 1
fi

# Check if logs directory exists, and if not create it
if [ ! -d $log_file ]; then
        logger E "$log_file does not exist, so creating it now!"
        mkdir -p $log_file
fi

# Check if secondary group exists, if not then create it
if [ $(getent group $secondary_group) ] 
then
    logger I "$secondary_group already exists"
else
    logger I "$secondary_group does not exist, creating it now..."
    groupadd $secondary_group 
fi 

for USER in `cat $names_file`
    do 
        if [ `getent group $USER` ]
        then
            logger I "$USER account already exists ... skipping"
            continue 
        else
            useradd -g $primary_group -G $secondary_group -s $user_shell -m $USER
            user_ssh_dir="/home/$USER/.ssh"
            mkdir -p $user_ssh_dir
            chown $USER: $user_ssh_dir 
            chmod 700 $USER: $user_ssh_dir 
            cp /home/ubuntu/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
            chown $USER: /home/$USER/.ssh/authorized_keys
            chmod 600 /home/$USER/.ssh/authorized_keys
            logger I "$USER account successfully created"
        fi
done