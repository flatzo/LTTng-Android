#!/usr/bin/env sh

# Fill following informations
# ==========================================

NDK=
SDK=
ANDROID_SOURCE=

make maintainer-clean

# Script variables
# ==========================================

DIR="$( cd "$( dirname "$0" )" && pwd )"
NDK_TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin

# Compilation environment
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
export CPPFLAGS="-I${SYSROOT}/usr/include" 
export CXXFLAGS=--sysroot=${SYSROOT}
export CFLAGS=--sysroot=${SYSROOT}
export LDFLAGS="--sysroot=$SYSROOT -L$SYSROOT/usr/lib -L$SYSROOT/lib" 

# Build steps 
# ==========================================

./bootstrap
CONFIG_SHELL=/bin/sh ./configure --host=arm-linux-androideabi --target=arm-linux-androideabi --prefix=/tmp/lttng LIBS="-lc -lgcc" $argStr
make
make install
