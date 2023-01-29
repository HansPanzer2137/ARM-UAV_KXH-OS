
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
KXH-CLFS=/mnt/clfs
LC_ALL=POSIX
PATH=${KXH-CLFS}/cross-tools/bin:/bin:/usr/bin
export KXH-CLFS LC_ALL PATH
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

export KXH_CLFS_ARCH=arm
#Banana Pi M2 Zero is a 32bit armv7l processor
#export arm arch choice

export KXH_CLFS_ARM_ARCH=armv7-a


echo export KXH_CLFS_HOST=\""${KXH_CLFS_HOST}\"" >> ~/.bashrc
echo export KXH_CLFS_TARGET=\""${KXH_CLFS_TARGET}\"" >> ~/.bashrc
echo export KXH_CLFS_ARCH=\""${KXH_CLFS_ARCH}\"" >> ~/.bashrc
echo export KXH_CLFS_ARM_ARCH=\""${KXH_CLFS_ARM_ARCH}\"" >> ~/.bashrc
echo export KXH_CLFS_FLOAT=\""${KXH_CLFS_FLOAT}\"" >> ~/.bashrc
echo export KXH_CLFS_FPU=\""${KXH_CLFS_FPU}\"" >> ~/.bashrc



mkdir -p ${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET}
ln -sfv . ${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET}/usr

make mrproper
make ARCH=${KXH_CLFS_ARCH} headers_check
make ARCH=${KXH_CLFS_ARCH} INSTALL_HDR_PATH=${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET} headers_install

mkdir -v ../binutils-build
cd ../binutils-build

../binutils-2.27/configure \
   --prefix=${KXH-CLFS}/cross-tools \
   --target=${KXH_CLFS_TARGET} \
   --with-sysroot=${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET} \
   --disable-nls \
   --disable-multilib

make configure-host
make
make install


tar xf ../mpfr-3.1.4.tar.bz2
mv -v mpfr-3.1.4 mpfr
tar xf ../gmp-6.1.1.tar.bz2
mv -v gmp-6.1.1 gmp
tar xf ../mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc

mkdir -v ../gcc-build
cd ../gcc-build


../gcc-6.2.0/configure \
  --prefix=${KXH-CLFS}/cross-tools \
  --build=${KXH_CLFS_HOST} \
  --host=${KXH_CLFS_HOST} \
  --target=${KXH_CLFS_TARGET} \
  --with-sysroot=${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET} \
  --disable-nls \
  --disable-shared \
  --without-headers \
  --with-newlib \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libatomic \
  --disable-libquadmath \
  --disable-threads \
  --enable-languages=c \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-6.2.0/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${KXH_CLFS_ARM_ARCH} \
  --with-float=${KXH_CLFS_FLOAT} \
  --with-fpu=${KXH_CLFS_FPU}

make all-gcc all-target-libgcc
make install-gcc install-target-libgcc



./configure \
  CROSS_COMPILE=${KXH_CLFS_TARGET}- \
  --prefix=/ \
  --target=${KXH_CLFS_TARGET}


make
DESTDIR=${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET} make install

tar xf ../mpfr-3.1.4.tar.bz2
mv -v mpfr-3.1.4 mpfr
tar xf ../gmp-6.1.1.tar.bz2
mv -v gmp-6.1.1 gmp
tar xf ../mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc


mkdir -v ../gcc-build
cd ../gcc-build

../gcc-6.2.0/configure \
  --prefix=${KXH-CLFS}/cross-tools \
  --build=${KXH_CLFS_HOST} \
  --host=${KXH_CLFS_HOST} \
  --target=${KXH_CLFS_TARGET} \
  --with-sysroot=${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET} \
  --disable-nls \
  --enable-languages=c \
  --enable-c99 \
  --enable-long-long \
  --disable-libmudflap \
  --disable-multilib \
  --with-mpfr-include=$(pwd)/../gcc-6.2.0/mpfr/src \
  --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
  --with-arch=${KXH_CLFS_ARM_ARCH} \
  --with-float=${KXH_CLFS_FLOAT} \
  --with-fpu=${KXH_CLFS_FPU}

make
make install

mkdir -pv ${KXH-CLFS}/targetfs


echo export CC=\""${KXH_CLFS_TARGET}-gcc --sysroot=${KXH-CLFS}/targetfs\"" >> ~/.bashrc
echo export CXX=\""${KXH_CLFS_TARGET}-g++ --sysroot=${KXH-CLFS}/targetfs\"" >> ~/.bashrc
echo export AR=\""${KXH_CLFS_TARGET}-ar\"" >> ~/.bashrc
echo export AS=\""${KXH_CLFS_TARGET}-as\"" >> ~/.bashrc
echo export LD=\""${KXH_CLFS_TARGET}-ld --sysroot=${KXH-CLFS}/targetfs\"" >> ~/.bashrc
echo export RANLIB=\""${KXH_CLFS_TARGET}-ranlib\"" >> ~/.bashrc
echo export READELF=\""${KXH_CLFS_TARGET}-readelf\"" >> ~/.bashrc
echo export STRIP=\""${KXH_CLFS_TARGET}-strip\"" >> ~/.bashrc
source ~/.bashrc

mkdir -pv ${KXH-CLFS}/targetfs/{bin,boot,dev,etc,home,lib/{firmware,modules}}
mkdir -pv ${KXH-CLFS}/targetfs/{mnt,opt,proc,sbin,srv,sys}
mkdir -pv ${KXH-CLFS}/targetfs/var/{cache,lib,local,lock,log,opt,run,spool}
install -dv -m 0750 ${KXH-CLFS}/targetfs/root
install -dv -m 1777 ${KXH-CLFS}/targetfs/{var/,}tmp
mkdir -pv ${KXH-CLFS}/targetfs/usr/{,local/}{bin,include,lib,sbin,share,src}


ln -svf ../proc/mounts ${KXH-CLFS}/targetfs/etc/mtab
cat > ${KXH-CLFS}/targetfs/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF


cat > ${KXH-CLFS}/targetfs/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
EOF

touch ${KXH-CLFS}/targetfs/var/log/lastlog
chmod -v 664 ${KXH-CLFS}/targetfs/var/log/lastlog

cp -v ${KXH-CLFS}/cross-tools/${KXH_CLFS_TARGET}/lib/libgcc_s.so.1 ${KXH-CLFS}/targetfs/lib/
${KXH_CLFS_TARGET}-strip ${KXH-CLFS}/targetfs/lib/libgcc_s.so.1

./configure \
  CROSS_COMPILE=${KXH_CLFS_TARGET}- \
  --prefix=/ \
  --disable-static \
  --target=${KXH_CLFS_TARGET}

make
DESTDIR=${KXH-CLFS}/targetfs make install-libs

make distclean
make ARCH="${KXH_CLFS_ARCH}" defconfig

sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config
sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config


sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' .config
sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' .config

sed -i 's/\(CONFIG_UDPSVD\)=y/# \1 is not set/' .config
sed -i 's/\(CONFIG_TCPSVD\)=y/# \1 is not set/' .config

make ARCH="${KXH_CLFS_ARCH}" CROSS_COMPILE="${KXH_CLFS_TARGET}-"

make ARCH="${KXH_CLFS_ARCH}" CROSS_COMPILE="${KXH_CLFS_TARGET}-" CONFIG_PREFIX=${KXH-CLFS}/targetfs install
cp -v examples/depmod.pl ${KXH-CLFS}/cross-tools/bin
chmod -v 755 ${KXH-CLFS}/cross-tools/bin/depmod.pl

patch -Np1 -i ../iana-etc-2.30-update-2.patch
make get
make STRIP=yes
make DESTDIR=${KXH-CLFS}/targetfs install

cat > ${KXH-CLFS}/targetfs/etc/fstab << "EOF"
# file-system  mount-point  type   options          dump  fsck
EOF

make mrproper
make ARCH="${KXH_CLFS_ARCH}" CROSS_COMPILE="${KXH_CLFS_TARGET}-" menuconfig
make ARCH=${KXH_CLFS_ARCH} CROSS_COMPILE=${KXH_CLFS_TARGET}-

make ARCH=${KXH_CLFS_ARCH} CROSS_COMPILE=${KXH_CLFS_TARGET}- \
    INSTALL_MOD_PATH=${KXH-CLFS}/targetfs modules_install
