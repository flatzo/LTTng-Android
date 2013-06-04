#!/usr/bin/env sh

. ./env.sh
cd src/lttng-tools

make distclean

# Compilation flags
# ==========================================

export CPPFLAGS="--sysroot=${SYSROOT} -I${SYSROOT}/usr/include -I${INSTALL_PATH}/include -D_FORTIFY_SOURCE=0"
export CXXFLAGS=--sysroot=${SYSROOT}
export CFLAGS="--sysroot=${SYSROOT}"
export LDFLAGS="--sysroot=${SYSROOT} -L${ANDROID_SOURCE}/out/target/product/generic/obj/SHARED_LIBRARIES/libc_intermediates/LINKED -L${SYSROOT}/lib -L${SYSROOT}/usr/lib -L${INSTALL_PATH}/lib"

# Build steps
# ==========================================

./bootstrap
./configure --host=arm-linux-androideabi --target=arm-linux-androideabi --prefix=${INSTALL_PATH} --disable-lttng-ust --program-prefix=''
make 
make install

# Pushing to device
# ==========================================

# adb shell "su -c 'mount -o remount,rw /data'"
# adb push $DESTDIR $REMOTE_INSTALL_PATH
# adb push android_test.sh $REMOTE_INSTALL_PATH
