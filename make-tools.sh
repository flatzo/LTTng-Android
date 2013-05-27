#!/usr/bin/env sh

# Fill following informations
# ==========================================

NDK=
SDK=
ANDROID_SOURCE=

# WARNING
# make sure you have permissions to this path on host computer
# This is needed as for the consumerd which is located in lib/lttng/libexec
INSTALL_PATH=/data/lttng-install
REMOTE_INSTALL_PATH=$INSTALL_PATH
export DESTDIR=/tmp/lttng-tools

NDK_TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin
PLATFORM_TOOLS=${SDK}/platform-tools
PATH=$PLATFORM_TOOLS:$PATH

# Toolchain environment
# ==========================================

export HOST=arm-linux-androideabi
export CROSS_COMPILE=arm-linux-androideabi
export CC=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-gcc
export CXX=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-g++
export LD=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ld
export AR=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ar
export RANLIB=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ranlib
export STRIP=${NDK_TOOLCHAIN}/${CROSS_COMPILE}-strip

export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes

platform=android-14
export SYSROOT=${NDK}/platforms/${platform}/arch-arm

# Compilation flags
# ==========================================

export CPPFLAGS="--sysroot=${SYSROOT} -I${SYSROOT}/usr/include -D_FORTIFY_SOURCE=0 -I${ANDROID_SOURCE}/external/oprofile/libpopt -I${ANDROID_SOURCE}/external/e2fsprogs/lib" 
export CXXFLAGS=--sysroot=${SYSROOT}
export CFLAGS="--sysroot=${SYSROOT}"
export LDFLAGS="--sysroot=${SYSROOT} -L${ANDROID_SOURCE}/out/target/product/generic/obj/SHARED_LIBRARIES/libc_intermediates/LINKED -L${SYSROOT}/lib -L${SYSROOT}/usr/lib -L${ANDROID_SOURCE}/out/target/product/generic/obj/SHARED_LIBRARIES/libc_intermediates/LINKED -L${ANDROID_SOURCE}/out/target/product/generic/obj/STATIC_LIBRARIES/liboprofile_popt_intermediates -L${INSTALL_PATH} -L${ANDROID_SOURCE}/out/target/product/generic/obj/SHARED_LIBRARIES/libext2_uuid_intermediates/LINKED" 

# Build steps
# ==========================================

./bootstrap
./configure --host=arm-linux-androideabi --target=arm-linux-androideabi --prefix=$INSTALL_PATH --disable-lttng-ust --program-prefix=''
make 
make destination
make install

# Pushing to device
# ==========================================

# adb shell "su -c 'mount -o remount,rw /data'"
# adb push $DESTDIR $REMOTE_INSTALL_PATH
# adb push android_test.sh $REMOTE_INSTALL_PATH
