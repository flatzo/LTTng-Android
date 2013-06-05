# Path to the root directories
NDK			:= /opt/android-ndk-r8e
SDK			:= /opt/android-sdk
KERNELDIR		:= 
DEVICE			:= grouper
VENDOR			:= asus
KERNEL_COMMIT		:= 05b777c
KERNEL_CONFIG		:= tegra3_android_defconfig

# Targeted Android platform version.
#
# In order to list possible platforms : 
#   ls ${NDK}/platforms
#
# API versions can be found on : 
#   http://developer.android.com/about/dashboards/index.html
#
PLATFORM		:= android-14

# Where to install temporary files on build machine
INSTALL_PATH		:= /tmp/lttng-android

# Where lttng will be installed on the device
# WARNING : Should not be the same path
#           as the one containing .../var/run
TARGET_INSTALL_PATH	:= /data/lttng-install

# Build platform 
# Select the one that fits best
BUILD_PLATFORM		:= linux-x86_64
#BUILD_PLATFORM		:= linux-x86
