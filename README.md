# PrawnOS Reprepro Docker (debian apt-get repository)

Debian package repository.

* Based upon: [the guide for setting up a private debian repository](http://wiki.debian.org/SettingUpSignedAptRepositoryWithReprepro).

## Building the image
```bash
$ ./create-image.sh
```

Now all that needs to be done is to provide the authorized_keys and gpg keys to the config folder structure

The config folder is assumed to be located at `~/reprepro-config`

create the folder structures
```bash
mkdir -p ~/reprepro-config/home/debian/.ssh/
mkdir -p ~/reprepro-config/home/debian/.gnupg/
```

### Setting up `authorized_keys`
The keys are required for adding packages to the system, and should be added to;
```bash
$CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Assuming you have generated a ssh key-set on the machine, you can do this by running;
```bash
$ export CONFIG_FOLDER=/home/config_here
$ cp ~/.ssh/id_rsa.pub $CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Generating a ssh key-set can be done by running;
```bash
$ ssh-keygen
```
And following the instructions.

### Setting up gpg-keys
The GPG keys are used for signing packages, they can be provided to;
```bash
$CONFIG_FOLDER/home/debian/.gnupg/master_pub.gpg
$CONFIG_FOLDER/home/debian/.gnupg/signing_sec.pgp
```
Generating gpg keys can be done by running;
```bash
$ gpg --gen-key
```

I suggest making a master with a long time to expire, then a signing sub key with a shorter
time to expire. Keep the master offline, and backed up. Export the master pub and the signing key
Then if your signing key is exposed, you can revoke it, and issue a new one with your safe offline master key. 

Right now you can only see the subkey key ids when you are in edit mode:
`gpg --edit-key`

See a good how to here https://www.debuntu.org/how-to-importexport-gpg-key-pair/
But remember to only export the master public key and the sub key private key.
Export the master key at a different time to back it up. 


## Running
The first time, we need to provide some configuration parameters
run
```
./prawnos-repo-first-run.sh
```
This will give log output for you to ensure everything is correct and
create the appropriate files in

```
$CONFIG_FOLDER/var/
$CONFIG_FOLDER/etc/
```

Once those are created, you can simply run
```
./prawnos-repo-run.sh
```
which will run the docker in the background

## Updating gpg keys
place they new keys in
```bash
$CONFIG_FOLDER/home/debian/.gnupg/master_pub.gpg
$CONFIG_FOLDER/home/debian/.gnupg/signing_sec.pgp
```

depending on how your new signing key is configured you may then have to manually import the key
```
docker exec -it --user debian <container-id> /bin/bash

sudo cp /srv/home/debian/.gnupg/signing_sec.gpg .
gpg --pinentry-mode loopback --import signing_sec.gpg
```

then update the repo

```
docker exec -it --user debian <container-id> /bin/bash

reprepro -b /var/www/repos/apt/debian/ export bullseye
```

you may have to request that your users re-import your public key as well using the instructions on the
repos webpage


## Reset the image
```
rm -rf ~/reprepro-config/etc/
rm -rf ~/reprepro-config/var/
```


## Uploading packages
inoticoming is used to watch an incoming folder for any new `.changes` files





## What follows below is the README for what this image is based on: 
https://github.com/SolidHal/reprepro-docker-http


## Running (stand-alone)
### Configuration done
Assuming the configuration is done, you can start the server as;
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -d solidhal/reprepro
```

### Configurating
There are three ways to configurate the image;

* Interactive
* Environmental
* Manual

Stand-alone (Interactive configuration);
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -it solidhal/reprepro
```

Stand-alone (Environemental configuration);
```bash
$ export CONFIG_FOLDER=/home/config_here
$ export WEBSERVER_PORT=8080
$ export SSH_PORT=2222
$ export HOSTNAME="{{YOUR-DOMAIN-NAME}}"
$ export PROJECT_NAME="{{NAME-OF-APT-REPO}}" 
$ export CODE_NAME="{{CODENAME-OF-OS-RELEASE}}" 
$ docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 \
             -e HOSTNAME=$HOSTNAME \
             -e PROJECT_NAME=$PROJECT_NAME -e CODE_NAME=$CODE_NAME \
             -it solidhal/reprepro
```

Stand-alone (Manual); The same as 'Configuration done'

### Configuration variables
#### Run configuration

* `$CONFIG_FOLDER`: The folder in which the reprepro configuration is stored.
* `$WEBSERVER_PORT`: The exposed nginx port (where packages are served).
* `$SSH_PORT`: The exposed openssh-port (which is used for uploading packages).

#### Setup configuration
*Note: Running in interactive configuration mode will prompth the user for this information.*

*Note: For manual configuration see the bottom of this file.*

* Gpg key information lower down

* `$HOSTNAME`: The hostname of the server (i.e. the url on which it's reached).
* `$PROJECT_NAME`: The name of the apt repository (can be anything).
* `$CODE_NAME`: The code-name of the os release for which packages will be served (wheezy/jessie/ect).

### Outside configuration
While most of the configuration can be done inside the container.

The `authorized_keys` file (for uploading packages) must be supplied from outside the container.

#### Setting up `authorized_keys`
The keys are required for adding packages to the system, and should be added to;
```bash
$CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Assuming you have generated a ssh key-set on the machine, you can do this by running;
```bash
$ export CONFIG_FOLDER=/home/config_here
$ cp ~/.ssh/id_rsa.pub $CONFIG_FOLDER/home/debian/.ssh/authorized_keys
```
Generating a ssh key-set can be done by running;
```bash
$ ssh-keygen
```
And following the instructions.

*Note: The image is able to run without `authorized_keys` being in place,
however uploading packages will not be an option then.*

## Uploading packages
The below assumes that you are in the folder of your `.deb` package.

The example is based upon uploading `kicad*.deb` (multiple packages).
```bash
$ export SSH_PORT=2222
$ export HOSTNAME="{{YOUR-DOMAIN-NAME}}"
$ export CODE_NAME="{{CODENAME-OF-OS-RELEASE}}"
$ scp -P SSH_PORT kicad*.deb debian@$HOSTNAME:
$ ssh -p SSH_PORT debian@$HOSTNAME "sudo chmod -R 777 /var/www/repos/"
$ ssh -p SSH_PORT debian@$HOSTNAME "reprepro -b /var/www/repos/apt/debian includedeb $CODE_NAME *.deb"
```

## Client Configuration
Once the repository is up and running, clients will need to be configured to use it.

The nginx webserver (which hosts the repository) has an index page with configuration information.

Assuming your hostname is `$HOSTNAME` head over to `http://$HOSTNAME/`, and these two commands will be shown;

### Registering the GPG public key
```bash
$ wget -O - http://$HOSTNAME/$HOSTNAME.gpg.key | apt-key add - 
```

### Registering the repository to `sources.list.d`
```bash
$ echo "deb http://$HOSTNAME/ $CODE_NAME main" > /etc/apt/sources.list.d/$HOSTNAME.list 
```

### Installing packages
At this point the repository is added, and you can run;
```bash
$ apt-get update
$ apt-get install $PACKAGE_NAME
```
To install `$PACKAGE_NAME` from your own repository to the client system.

*Note: The repository is non-functional until the first package has been added.*

## Manual configuration
Instead of using the interactive or environmental configuration,
you can simply provide your own configuration files inside `$CONFIG_FOLDER`,
alike how it was done with the `authorized_keys` file.

### Setting up `authorized_keys`
See the section above.

### Setting up gpg-keys
The GPG keys are used for signing packages, they can be provided to;
```bash
$CONFIG_FOLDER/home/debian/.gnupg/master_pub.gpg
$CONFIG_FOLDER/home/debian/.gnupg/signing_sec.pgp
```
Generating gpg keys can be done by running;
```bash
$ gpg --gen-key
```

I suggest making a master with a long time to expire, then a signing sub key with a shorter
time to expire. Keep the master offline, and backed up. Export the master pub and the signing key
Then if your signing key is exposed, you can revoke it, and issue a new one with your safe offline master key. 

Right now you can only see the subkey key ids when you are in edit mode:
`gpg --edit-key`

See a good how to here https://www.debuntu.org/how-to-importexport-gpg-key-pair/
But remember to only export the master public key and the sub key private key.
Export the master key at a different time to back it up. 

### Setting up nginx
The nginx `sites-enabled` file can be provided as:
```bash
$CONFIG_FOLDER/etc/nginx/sites-enabled/reprepro-repository
```

### Setting up reprepro
The reprepro configuration file can be provided as;
```bash
$CONFIG_FOLDER/var/www/repos/apt/debian/conf/options
```
