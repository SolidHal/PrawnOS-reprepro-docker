#!/bin/bash

# Prepare nginx serve folder
mkdir -p /var/www/repos/apt/debian
# Prepare reprepro configuration folder
mkdir -p /var/www/repos/apt/debian/conf

# SSH authorized keys
AUTHORIZED_KEYS=/home/debian/.ssh/authorized_keys
AUTHORIZED_KEYS_MOUNT=$(echo "/srv$AUTHORIZED_KEYS")
if [ ! -f $AUTHORIZED_KEYS_MOUNT ]; then
    SSH_KEY_DIR=$(dirname $AUTHORIZED_KEYS_MOUNT)
    echo "---SSH-KEYS---"
    echo "Warning: No authorized_keys file found!"
    echo " Please provide one to: \$CONFIG_DIR$AUTHORIZED_KEYS"
    mkdir -p $SSH_KEY_DIR
    echo ""
else
    cp $AUTHORIZED_KEYS_MOUNT $AUTHORIZED_KEYS
    chown debian:debian $AUTHORIZED_KEYS
fi



# GPG-keys
# pass in the master public key and
# a new signing sub key
GPG_PUBLIC=/home/debian/.gnupg/master_pub.gpg
GPG_PUBLIC_MOUNT=$(echo "/srv$GPG_PUBLIC")

GPG_SECRET=/home/debian/.gnupg/signing_sec.gpg
GPG_SECRET_MOUNT=$(echo "/srv$GPG_SECRET")

if [ ! -f $GPG_PUBLIC_MOUNT ] || [ ! -f $GPG_SECRET_MOUNT ]; then
    echo "---GPG-KEYS---"
    echo "Warning: No GPG keys found!"
    echo " Please provide a pair to: \$CONFIG_DIR$GPG_KEY_DIR"
else
    cp $GPG_PUBLIC_MOUNT $GPG_PUBLIC
    cp $GPG_SECRET_MOUNT $GPG_SECRET
    sudo -u debian gpg --import $GPG_PUBLIC $GPG_SECRET
fi

sudo -u debian gpg --list-keys > /dev/null 2> /dev/null
KEY_ID=$(sudo -u debian gpg --list-keys | head -4 | tail -1 | sed -e 's/^[[:space:]]*//')
# echo "KEY_ID: $KEY_ID"

# Nginx configuration
NGINX_CONFIGURATION=/etc/nginx/sites-enabled/reprepro-repository
NGINX_CONFIGURATION_MOUNT=$(echo "/srv$NGINX_CONFIGURATION")
if [ ! -f $NGINX_CONFIGURATION_MOUNT ]; then
    NGINX_DIR=$(dirname $NGINX_CONFIGURATION_MOUNT)
    echo "---NGINX---"
    echo "Warning: No nginx configuration file found"
    echo " Please provide one to: \$CONFIG_DIR$NGINX_CONFIGURATION"
    mkdir -p $NGINX_DIR
    echo ""

    echo -e "Auto: Generating configuration \c"
    if [[ -z "$HOSTNAME" ]]; then
        echo "in interactive mode;"
        echo -e "Hostname: \c"
        read HOSTNAME
        echo ""
    else
        echo "in batch-mode."
    fi

    cat /templates/reprepro-repository | sed "s/!!!HOST_NAME_HERE!!!/$HOSTNAME/g" > $NGINX_CONFIGURATION_MOUNT

    echo "Configuration file created!"
    echo ""
else
    HOSTNAME=$(cat $NGINX_CONFIGURATION_MOUNT | grep "server_name" | sed "s/\s*server_name\s\(.*\);/\1/g")
fi
cp $NGINX_CONFIGURATION_MOUNT $NGINX_CONFIGURATION

#echo "HOSTNAME: $HOSTNAME"

# Reprepro configuration
# Distributions
REPREPRO_DISTRIBUTIONS=/var/www/repos/apt/debian/conf/distributions
REPREPRO_DISTRIBUTIONS_MOUNT=$(echo "/srv$REPREPRO_DISTRIBUTIONS")
if [ ! -f $REPREPRO_DISTRIBUTIONS_MOUNT ]; then
    REPREPRO_DIR=$(dirname $REPREPRO_DISTRIBUTIONS_MOUNT)
    echo "---REPREPRO---"
    echo "Warning: No reprepro distributions configuration file found"
    echo " Please provide one to: \$CONFIG_DIR$REPREPRO_DISTRIBUTIONS"
    mkdir -p $REPREPRO_DIR
    echo ""

    echo -e "Auto: Generating configuration \c"
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "in interactive mode;"
        echo -e "Project Name: \c"
        read PROJECT_NAME
        echo ""
    else
        echo "in batch-mode."
    fi

    if [[ -z "$CODE_NAME" ]]; then
        echo -e "Codename (wheezy/jessie): \c"
        read CODE_NAME
        echo ""
    fi

    cat /templates/distributions | sed "s/!!!PROJECT_NAME_HERE!!!/$PROJECT_NAME/g" | sed "s/!!!CODE_NAME_HERE!!!/$CODE_NAME/g" | sed "s/!!!KEY_ID_HERE!!!/$KEY_ID/g" |  sed "s/!!!SUITE_HERE!!!/$SUITE/g" > $REPREPRO_DISTRIBUTIONS_MOUNT

    echo "Configuration file created!"
    echo ""
else
    PROJECT_NAME=$(cat $REPREPRO_DISTRIBUTIONS_MOUNT | grep "Origin" | sed "s/Origin:\s\(.*\)/\1/g")
    CODE_NAME=$(cat $REPREPRO_DISTRIBUTIONS_MOUNT | grep "Codename" | sed "s/Codename:\s\(.*\)/\1/g")
fi
cp $REPREPRO_DISTRIBUTIONS_MOUNT $REPREPRO_DISTRIBUTIONS 

#echo "PROJECT_NAME: $PROJECT_NAME"
#echo "CODE_NAME: $CODE_NAME"

# Options
REPREPRO_OPTIONS=/var/www/repos/apt/debian/conf/options
REPREPRO_OPTIONS_MOUNT=$(echo "/srv$REPREPRO_OPTIONS")
if [ ! -f $REPREPRO_OPTIONS_MOUNT ]; then
    REPREPRO_DIR=$(dirname $REPREPRO_DISTRIBUTIONS_MOUNT)
    echo "---REPREPRO---"
    echo "Warning: No reprepro distributions configuration file found"
    echo " Please provide one to: \$CONFIG_DIR$REPREPRO_OPTIONS"
    mkdir -p $REPREPRO_DIR
    echo ""

    echo "Auto: Generating configuration; default"

    cat /templates/options > $REPREPRO_OPTIONS_MOUNT

    echo "Configuration file created!"
    echo ""
fi
cp $REPREPRO_OPTIONS_MOUNT $REPREPRO_OPTIONS

# Override
REPREPRO_OVERRIDE=$(echo "/var/www/repos/apt/debian/conf/override.$CODE_NAME")
REPREPRO_OVERRIDE_MOUNT=$(echo "/srv$REPREPRO_OPTIONS")
if [ ! -f $REPREPRO_OVERRIDE_MOUNT ]; then
    REPREPRO_DIR=$(dirname $REPREPRO_OVERRIDE_MOUNT)
    echo "---REPREPRO---"
    echo "Warning: No reprepro distributions configuration file found"
    echo " Please provide one to: \$CONFIG_DIR$REPREPRO_OVERRIDE"
    mkdir -p $REPREPRO_DIR
    echo ""

    echo "Auto: Generating configuration; default"

    cat /templates/override > $REPREPRO_OVERRIDE_MOUNT

    echo "Configuration file created!"
    echo ""
fi
cp $REPREPRO_OVERRIDE_MOUNT $REPREPRO_OVERRIDE

# Incoming
REPREPRO_INCOMING=/var/www/repos/apt/debian/conf/incoming
REPREPRO_INCOMING_MOUNT=$(echo "/srv$REPREPRO_INCOMING")
if [ ! -f $REPREPRO_INCOMING_MOUNT ]; then
    REPREPRO_DIR=$(dirname $REPREPRO_INCOMING_MOUNT)
    echo "---REPREPRO---"
    echo "Warning: No reprepro incoming configuration file found"
    echo " Please provide one to: \$CONFIG_DIR$REPREPRO_INCOMING"
    mkdir -p $REPREPRO_DIR
    echo ""

    echo "Auto: Generating configuration; default"

    cp /templates/incoming $REPREPRO_INCOMING_MOUNT

    echo "Configuration file created!"
    echo ""
fi
cp $REPREPRO_INCOMING_MOUNT $REPREPRO_INCOMING

REPREPRO_INCOMING_FOLDER=/var/www/repos/apt/debian/incoming
REPREPRO_INCOMING_TMP_FOLDER=/var/www/repos/apt/debian/tmp
REPREPRO_INCOMING_LOG_FOLDER=/var/www/repos/apt/debian/log
mkdir -p $REPREPRO_INCOMING_FOLDER
mkdir -p $REPREPRO_INCOMING_FOLDER
mkdir -p $REPREPRO_INCOMING_LOG_FOLDER

chown -R debian:debian /var/www/repos/

# Make this a part of stuff
cd /home/debian/
sudo -u debian gpg --armor --output $HOSTNAME.gpg.key --export $KEY_ID
mv $HOSTNAME.gpg.key /var/www/repos/apt/debian/$HOSTNAME.gpg.key
# Make index.html
cat /templates/index.html | sed "s/!!!HOST_NAME_HERE!!!/$HOSTNAME/g" | sed "s/!!!CODE_NAME_HERE!!!/$CODE_NAME/g" > /var/www/repos/apt/debian/index.html

echo "startup inotify for incoming"
inoticoming --logfile $REPREPRO_INCOMING_LOG_FOLDER/upload.log $REPREPRO_INCOMING_FOLDER --stderr-to-log --stdout-to-log --suffix '.changes' sudo -u debian reprepro --waitforlock 100 -b /var/www/repos/apt/debian processincoming default \;

echo "Running sshd and nginx"
# Start up the webserver
/usr/sbin/nginx
# ... and the ssh daemon
/usr/sbin/sshd -D
