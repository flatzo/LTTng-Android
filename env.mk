include fill_out.mk

NDK_TOOLCHAIN 		:= ${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/${BUILD_PLATFORM}/bin
PLATFORM_TOOLS		:= ${SDK}/platform-tools
PATH				:= ${PLATFORM_TOOLS}:${PATH}

# Toolchain environment
# ==========================================

HOST			:= arm-linux-androideabi
CROSS_COMPILE 	:= arm-linux-androideabi
SYSROOT			:= ${NDK}/platforms/${PLATFORM}/arch-arm

CC				:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-gcc
CXX				:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-g++
LD				:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ld
AR				:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ar
RANLIB			:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-ranlib
STRIP			:= ${NDK_TOOLCHAIN}/${CROSS_COMPILE}-strip

ac_cv_func_malloc_0_nonnull := yes
ac_cv_func_realloc_0_nonnull := yes

export ARCH
export HOST
export CROSS_COMPILE
export SYSROOT

export CC
export CXX
export LD
export AR
export RANLIB
export STRIP

export ac_cv_func_malloc_0_nonnull
export ac_cv_func_realloc_0_nonnull

# Compilation flags 
# ==========================================

CPPFLAGS 	:= --sysroot=${SYSROOT} -I${SYSROOT}/usr/include -I${SYSROOT}/include -I${INSTALL_PATH}/include -D_FORTIFY_SOURCE=0
CXXFLAGS	:= --sysroot=${SYSROOT}
CFLAGS		:= --sysroot=${SYSROOT}
LDFLAGS		:= --sysroot=${SYSROOT} -L${SYSROOT}/usr/lib -L${SYSROOT}/lib -L${INSTALL_PATH}/lib

export CPPFLAGS
export CXXFLAGS
export CFLAGS
export LDFLAGS

CONFIGURE_OPTIONS 	:= --host=${HOST} --target=${HOST} --prefix=${INSTALL_PATH}
