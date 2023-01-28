
#!/bin/bash

sudo mkdir -p /mnt/clfs
export KXH-CLFS=/mnt/clfs

sudo chmod 777 ${KXH-CLFS}
mkdir -v ${KXH-CLFS}/sources

echo "adding clfs user"
sudo groupadd kxh-clfs
sudo useradd -s /bin/bash -g kxh-clfs -m -k /dev/null kxh-clfs

echo "adding clfs user password"
sudo passwd kxh-clfs

sudo chown -Rv clfs ${KXH-CLFS}
su - kxh-clfs


cat > ~/.bash_profile << "EOF"
exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS=/mnt/clfs
LC_ALL=POSIX
PATH=${CLFS}/cross-tools/bin:/bin:/usr/bin
export CLFS LC_ALL PATH
EOF

source ~/.bash_profile

unset CFLAGS
echo unset CFLAGS >> ~/.bashrc

#okay so there is a some kind of "work for you" place. 
# https://clfs.org/view/clfs-embedded/arm/cross-tools/variables.html check that shit and ajust it to your needs
# im using a Orange Pi Zero with a 32bit armv7l processor

export KXH_CLFS_FLOAT=hard
export KXH_CLFS_FPU=vfpv4

export KXH_CLFS_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
export KXH_CLFS_TARGET=arm-linnux-musleabihf

export