# Path to the root directories
NDK			:= /opt/android/ndk
SDK			:= /opt/android/sdk
ANDROID_BUILD_TOP	:= /home/charles/android/aosp
ANDROID_TREE		:= $(ANDROID_BUILD_TOP)
PRODUCT			:= generic
KERNELDIR		:= /home/charles/Downloads/sm-n900/kernel

export ANDROID_BUILD_TOP

# Select the device to build kernel modules for
# Supported devices are located in the devices folder.
include devices/note3.mk

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
TARGET_MODULES_DIR	:= /sdcard/extra

export TARGET_MODULES_DIR

# This path needs to be writable for the adb push
PACKAGE_PUSH_PATH	:= /sdcard/lttng-android.tar

# Override automatic detection of build platform
#BUILD_PLATFORM		:= linux-x86_64
#BUILD_PLATFORM		:= linux-x86
