
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