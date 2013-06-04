#!/usr/bin/env sh

. ./env.sh
cd src/popt

make clean

# Compilation environment
# ==========================================

export CPPFLAGS="-I${SYSROOT}/usr/include"
export CXXFLAGS=--sysroot=${SYSROOT}
export CFLAGS=--sysroot=${SYSROOT}
export LDFLAGS="--sysroot=$SYSROOT -L$SYSROOT/usr/lib -L$SYSROOT/lib -L$INSTALL_PATH" 

# Build steps 
# ==========================================

autoreconf -i
./configure --host=arm-linux-androideabi --target=arm-linux-androideabi --prefix=${INSTALL_PATH} LIBS="-lc -lgcc"

make
make install
