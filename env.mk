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
export TOOLS_DIR		:= ${CWD}/lttng-tools
export TARGET_ROOT		:= ${INSTALL_PATH}${TARGET_INSTALL_PATH}


LIBXML2_CPPFLAGS	:= -DLIBXML_SCHEMAS_ENABLED -I${ANDROID_TREE}/external/libxml2/include \
				-I${ANDROID_TREE}/external/icu4c/common
ifdef ANDROID_TREE
# KERNEL_TOOLCHAIN	:= ${ANDROID_TREE}/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3
# KERNEL_TOOLCHAIN	:= ${ANDROID_TREE}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7
TOOLCHAIN		:= ${ANDROID_TREE}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.6
# HOST			:= arm-eabi
HOST			:= arm-linux-androideabi
SYSROOT			:= ${ANDROID_TREE}/out/target/product/${PRODUCT}/obj
FLAGS_UUID		:= -I${ANDROID_TREE}/external/e2fsprogs/lib
LIBXML2_LDFLAGS 	:= # -lxml2 # -L${SYS_ROOT}/STATIC_LIBRARIES/libxml2_intermediates
else
TOOLCHAIN		:= ${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/${BUILD_PLATFORM}
HOST			:= arm-linux-androideabi
SYSROOT			:= ${NDK}/platforms/${PLATFORM}/arch-arm
endif

PLATFORM_TOOLS		:= ${SDK}/platform-tools
PATH			:= ${PLATFORM_TOOLS}:${PATH}

# Toolchain environment
# ==========================================

export ARCH			:= arm
export SUBARCH			:= arm
export CROSS_COMPILE		:= ${TOOLCHAIN}/bin/${HOST}-

export HOST SYSROOT

export AR			:= ${CROSS_COMPILE}ar
export AS			:= ${CROSS_COMPILE}as
export CC			:= ${CROSS_COMPILE}gcc
export CPP			:= ${CC} -E
export CXX			:= ${CROSS_COMPILE}g++
export LD			:= ${CROSS_COMPILE}ld
export NM			:= ${CROSS_COMPILE}nm
export OBJCOPY			:= ${CROSS_COMPILE}objcopy
export OBJDUMP			:= ${CROSS_COMPILE}objdump
export RANLIB			:= ${CROSS_COMPILE}ranlib
export READELF			:= ${CROSS_COMPILE}readelf
export SIZE			:= ${CROSS_COMPILE}size
export STRINGS			:= ${CROSS_COMPILE}strings
export STRIP			:= ${CROSS_COMPILE}strip

export ac_cv_func_malloc_0_nonnull	:= yes
export ac_cv_func_realloc_0_nonnull	:= yes

# Compilation flags
# ==========================================

CPPFLAGS	:= --sysroot=${SYSROOT} -gstabs+ -rdynamic \
			-I${ANDROID_TREE}/bionic/libc/include \
			-I${ANDROID_TREE}/bionic/libc/kernel/common \
			-I${ANDROID_TREE}/bionic/libc/kernel/arch-arm \
			-I${ANDROID_TREE}/bionic/libc/arch-arm/include \
			-I${ANDROID_TREE}/bionic/libm/include \
			-I${ANDROID_TREE}/system/core/include \
			-I${SYSROOT}/usr/include \
			-I${SYSROOT}/include \
			-I${INSTALL_PATH}/${TARGET_INSTALL_PATH}/include \
			${FLAGS_UUID} ${LIBXML2_CPPFLAGS}
# -D_FORTIFY_SOURCE=0
CXXFLAGS	:= --sysroot=${SYSROOT}
CFLAGS		:= --sysroot=${SYSROOT} -O0 -Wall -fno-short-enums -mandroid -w # -fPIC
LDFLAGS		:= --sysroot=${SYSROOT} -L${SYSROOT}/usr/lib -L${SYSROOT}/lib -L${INSTALL_PATH}/${TARGET_INSTALL_PATH}/lib ${LIBXML2_LDFLAGS} -lm # -inst-prefix-dir=${TARGET_INSTALL_PATH}/lib
LIBDIR		:= ${INSTALL_PATH}${TARGET_INSTALL_PATH}/lib
ifdef ANDROID_TREE
# LDFLAGS		+= -nostdlib -nostartfiles -ffreestanding -Wl,-dynamic-linker,/system/bin/linker -lc -ldl
#  -nodefaultlibs
endif
# ${SYSROOT}/lib/crtbegin_dynamic.o ${SYSROOT}/lib/crtend_android.o

export CPPFLAGS CXXFLAGS CFLAGS LDFLAGS
export LIBDIR LD_LIBRARY_PATH LD_RUN_PATH
export DESTDIR=${INSTALL_PATH}

CONFIGURE_OPTIONS	:= --host=${HOST} --target=${HOST} --prefix=${TARGET_INSTALL_PATH}
