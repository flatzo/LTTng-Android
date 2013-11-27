CWD = $(shell pwd)
HOST_ARCH = $(shell uname -m)

include fill_out.mk

ifeq (${HOST_ARCH}, x86_64)
BUILD_PLATFORM ?= linux-x86_64
else ifeq (${HOST_ARCH}, i686)
BUILD_PLATFORM ?= linux-x86
else
$(error Unsupported host arch ${HOST_ARCH})
endif

# default values for SDK/NDK
NDK_VERSION ?= android-ndk-r8e
SDK_VERSION ?= r22.0.1

NDK ?= ${CWD}/ndk/${NDK_VERSION}
SDK ?= ${CWD}/sdk/android-sdk-linux

NDK_BASE := $(shell dirname ${NDK})
SDK_BASE := $(shell dirname ${SDK})

NDK_URL ?= http://dl.google.com/android/ndk/${NDK_VERSION}-${BUILD_PLATFORM}.tar.bz2
SDK_URL ?= http://dl.google.com/android/android-sdk_${SDK_VERSION}-linux.tgz

export KERNELDIR

# Folders locations
# ==========================================
export MODULES_DIR		:= ${CWD}/src/modules
export TOOLS_DIR		:= ${CWD}/src/tools


NDK_TOOLCHAIN		:= ${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/${BUILD_PLATFORM}/bin
PLATFORM_TOOLS		:= ${SDK}/platform-tools
PATH			:= ${PLATFORM_TOOLS}:${PATH}

# Toolchain environment
# ==========================================

export ARCH			:= arm
export HOST			:= arm-linux-androideabi
export CROSS_COMPILE		:= ${NDK_TOOLCHAIN}/arm-linux-androideabi-
export SYSROOT			:= ${NDK}/platforms/${PLATFORM}/arch-arm

export CC			:= ${CROSS_COMPILE}gcc
export CXX			:= ${CROSS_COMPILE}g++
export LD			:= ${CROSS_COMPILE}ld
export AR			:= ${CROSS_COMPILE}ar
export RANLIB			:= ${CROSS_COMPILE}ranlib
export STRIP			:= ${CROSS_COMPILE}strip

export ac_cv_func_malloc_0_nonnull	:= yes
export ac_cv_func_realloc_0_nonnull	:= yes

# Compilation flags 
# ==========================================

export CPPFLAGS	:= --sysroot=${SYSROOT} -I${SYSROOT}/usr/include -I${SYSROOT}/include -I${INSTALL_PATH}/include -D_FORTIFY_SOURCE=0
export CXXFLAGS	:= --sysroot=${SYSROOT}
export CFLAGS	:= --sysroot=${SYSROOT}
export LDFLAGS	:= --sysroot=${SYSROOT} -L${SYSROOT}/usr/lib -L${SYSROOT}/lib -L${INSTALL_PATH}/lib

CONFIGURE_OPTIONS	:= --host=${HOST} --target=${HOST} --prefix=${TARGET_INSTALL_PATH}
