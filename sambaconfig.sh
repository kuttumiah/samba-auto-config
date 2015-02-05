#!/bin/bash

# /**
# * ================================================================================
# * This script will be used to automate samba file share configuration.
# * The file will operate on and modify '/etc/samba/smb.conf' file.
# * @author             Robaiatul Islam Shaon
# * @version            0.1
# * @created            02 February 2015 15:50
# * @last modified      Robaiatul Islam Shaon on 04 February 2015 14:57
# * @see                https://bitbucket.org/kuttumiah/odesk-job-florian
# * ================================================================================
# */

# configuring for samba server
OPTION=1

# global configuration variables
WORKGROUP="WORKGROUP"
S_STRING="File Server"
MAX_LOG_SIZE="50"
HOST_ALLOW="127. 192.168.10."
PROXY="no"

# shared directory configuration variables
SHARE_DIRECTORY="storage"
DIRECTORY_PATH="/usr/share/xshare"
DIRECTORY_MASK="0777"
FILE_MASK="0765"
FORCE_USER="zersiax"
FORCE_GROUP="users"

# start function to check conflict on shared directory name
function directory_name_conflict_chack () {
    if grep -Fxq "[$SHARE_DIRECTORY]" /etc/samba/smb.conf
    then
        echo "This name already exists. Please enter another."
        read -p "Name of shared directory [$SHARE_DIRECTORY] " SHARE_DIRECTORY
    else
        DIRECTORY_NAME_CONFLICT=false
    fi
}
# end function to check conflict on shared directory name

# start function to check conflict on shared directory path
function directory_conflict_chack () {
    CHOICE="yes"
    if grep -Fq "$DIRECTORY_PATH" /etc/samba/smb.conf
    then
        echo "This directory is already shared using another name."
        echo "Would you like to change the directory? yes/no"

        read -p "Enter your choice [$CHOICE] " CHOICE
        if [[ -z "$CHOICE" ]]; then
            CHOICE="yes"
        fi
        
        case "$CHOICE" in
           [yY] | [yY][Ee][Ss])
              read -p "Shared directory path [$DIRECTORY_PATH] " DIRECTORY_PATH
              DIRECTORY_PATH="${DIRECTORY_PATH:="/usr/share/xshare"}"
              directory_conflict_chack
              ;; 
           [nN] | [nN][oO])
              return 0
              ;; 
           *)  
              echo "Please enter only 'yes' or 'no'" 
              directory_conflict_chack
              ;;
        esac
    else
        DIRECTORY_CONFLICT=false
    fi
}
# end function to check conflict on shared directory path


# start function to get global variables for config
function global_values () {
    # global configuration parameters
    echo "[global]" | sudo tee /etc/samba/smb.conf > /dev/null
    
    read -p "Name of the Workgroup of your host machine [$WORKGROUP] " WORKGROUP
    while [[ -z "$WORKGROUP" ]]; do
        WORKGROUP="WORKGROUP"
    done
    echo "Selected Workgroup is $WORKGROUP"
    
    read -p "Name of the Server String [$S_STRING] " S_STRING
    while [[ -z "$S_STRING" ]]; do
        S_STRING="File Server"
    done
    echo "Selected Server String is $S_STRING"
    
    read -p "Maximux log size [$MAX_LOG_SIZE] " MAX_LOG_SIZE
    while [[ -z "$MAX_LOG_SIZE" ]]; do
        MAX_LOG_SIZE="50"
    done
    echo "Maximux log size is $MAX_LOG_SIZE KB"
    
    read -p "Allowed hosts [$HOST_ALLOW] " HOST_ALLOW
    while [[ -z "$HOST_ALLOW" ]]; do
        HOST_ALLOW="127. 192.168.10."
    done
    echo "Allowed hosts are $HOST_ALLOW"
    
    read -p "proxy [$PROXY] " PROXY
    while [[ -z "$PROXY" ]]; do
        PROXY="no"
    done
    echo "Proxy is set to $PROXY"
}
# end function to get global variables for config

# start function to get shared directory variables for config
function directory_values () {
    # shared directory configuration parameters

    read -p "Name of shared directory [$SHARE_DIRECTORY] " SHARE_DIRECTORY
    DIRECTORY_NAME_CONFLICT=true
    while [[ $DIRECTORY_NAME_CONFLICT != false ]]; do
        if [[ -z "$SHARE_DIRECTORY" ]]; then
            SHARE_DIRECTORY="storage"
            directory_name_conflict_chack
        else
            directory_name_conflict_chack
        fi
    done
    echo "Find shared files on directory $SHARE_DIRECTORY"

    read -p "Shared directory path [$DIRECTORY_PATH] " DIRECTORY_PATH
    DIRECTORY_CONFLICT=true
    while [[ $DIRECTORY_CONFLICT != false ]]; do
        if [[ -z "$DIRECTORY_PATH" ]]; then
            DIRECTORY_PATH="/usr/share/xshare"
            directory_conflict_chack
        else
            directory_conflict_chack
        fi
        if [ "${CHOICE,,}" == "n" ] || [ "${CHOICE,,}" == "no" ]
        then
            break
        fi
    done
    echo "Find shared files on $DIRECTORY_PATH"
    
    echo "Newly created directory/file owner (User)"
    echo "User must be an existing user. Otherwise share will break."
    read -p "Enter owner (User) [$FORCE_USER] " FORCE_USER
    while [[ -z "$FORCE_USER" ]]; do
        FORCE_USER="zersiax"
    done
    echo "Newly created directory/file owner user $FORCE_USER"
    
    echo "Newly created directory/file owner (Group)"
    echo "Group must be an existing group. Otherwise share will break."
    read -p "Newly created directory/file owner (Group) [$FORCE_GROUP] " FORCE_GROUP
    while [[ -z "$FORCE_GROUP" ]]; do
        FORCE_GROUP="users"
    done
    echo "Newly created directory/file owner group $FORCE_GROUP"
    
    read -p "Mask of the newly created directory [$DIRECTORY_MASK] " DIRECTORY_MASK
    DIRECTORY_MASK=${DIRECTORY_MASK:=0777}
    while [[ ! $DIRECTORY_MASK =~ ^0[0-7]{3}$ ]]; do
        read -p "Enter only number, please [0777] " DIRECTORY_MASK
        DIRECTORY_MASK=${DIRECTORY_MASK:=0777}
    done
    echo "Newly created directory permission is $DIRECTORY_MASK"
    
    read -p "Permission of newly created file [$FILE_MASK] " FILE_MASK
    FILE_MASK=${FILE_MASK:=0765}
    while [[ ! $FILE_MASK =~ ^0[0-7]{3}$ ]]; do
        read -p "Enetr only number, please [0765] " FILE_MASK
        FILE_MASK=${FILE_MASK:=0765}
    done
    echo "Newly created file permission is $FILE_MASK"
}
# end function to get shared directory variables for config

# start function to write global settings in config
function global_config () {
    {
    # global configuration
    echo -e "\tworkgroup = $WORKGROUP"
    echo -e "\tserver string = $S_STRING"
    echo -e "\tsecurity = user"
    echo -e "\tmap to guest = Bad User"
    echo -e "\tlog file = /var/log/samba/%m.log"
    echo -e "\tmax log size = $MAX_LOG_SIZE"
    echo -e "\thosts allow = $HOST_ALLOW"
    echo -e "\tdns proxy = $PROXY"
    } | sudo tee -a /etc/samba/smb.conf > /dev/null
}
# end function to write global settings in config

# start function to write shared directory settings in config
function directory_config () {
    {
    # add line gap before directory configuration
    echo
    
    # shared directory configuration
    echo "[$SHARE_DIRECTORY]"
    echo -e "\tpath = $DIRECTORY_PATH"
    echo -e "\tavailable = yes"
    echo -e "\tbrowsable = yes"
    echo -e "\tpublic = yes"
    echo -e "\tonly guest = yes"
    echo -e "\twritable = yes"
    echo -e "\tforce user = $FORCE_USER"
    echo -e "\tforce group = $FORCE_GROUP"
    echo -e "\tdirectory mask = $DIRECTORY_MASK"
    echo -e "\tcreate mask = $FILE_MASK"
    } | sudo tee -a /etc/samba/smb.conf > /dev/null
}
# end function to write shared directory settings in config


# start function to initialize the script
function initialize_script () {
    echo "Please choose one from below."
    echo "1) Create new configuration file for SAMBA"
    echo "2) Add new directory to share"
    echo "3) Exit"
    read -p "Enter your choice [$OPTION] " OPTION
    OPTION=${OPTION:=1}
    while [[ ! $OPTION =~ ^[1-3]{1}$ ]]; do
        read -p "Enetr only number, please [1] " OPTION
        OPTION=${OPTION:=1}
    done
  
    case ${OPTION} in
       1)
          global_values
          directory_values
          global_config
          directory_config
          ;; 
       2)
          if [[ -f /etc/samba/smb.conf ]]; then
              directory_values
              directory_config
          else
              echo "There is no configuration file exists. Please select 1 to create."
              OPTION=1 && initialize_script
          fi
          ;; 
       3)  
          echo "You choose to abort $(basename "${0}") from running. Exiting..." 
          exit 1 # Command to come out of the program with status 1
          ;; 
    esac
}
# end function to initialize the script


# initial function call to start the script
initialize_script

# details of the config file
echo -e "\nYour configuration will be..."
echo "=================================================="
testparm -s
echo "=================================================="
echo
echo "Please run \"sudo systemctl restart smbd nmbd\" to restart samba and to take effect of changes on Arch Linux."
read -p "Press any key to continue... " -n1 -s
echo

# references:
# default value for variables: http://stackoverflow.com/a/2013589
# accept only numbers (regular expression): http://www.regular-expressions.info/numericranges.html
# linux case statement: http://www.tutorialspoint.com/unix/case-esac-statement.htm
# linux case statement user input (No 4 example): http://www.thegeekstuff.com/2010/07/bash-case-statement/
# check a string if exists: http://stackoverflow.com/a/4749368
# there is a warning running `testparm`. details and workaround on that warning: http://serverfault.com/a/641411
