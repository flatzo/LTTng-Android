#!/usr/bin/env sh

# Fill following informations
# ==========================================

NDK=
SDK=
ANDROID_SOURCE=

# Script variables
# ==========================================

DIR="$( cd "$( dirname "$0" )" && pwd )"
REMOTE_INSTALL_PATH=/data/lttng-modules
NDK_TOOLCHAIN=${NDK}/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin

# Compilation environment
# ==========================================

export ARCH=arm
export CROSS_COMPILE=${NDK_TOOLCHAIN}/arm-linux-androideabi-

export KERNELDIR=/home/charles/android-kernel/tegra
export PATH=$PLATFORM_TOOLS:$PATH

# Build steps 
# ==========================================
mkdir ${DIR}/out

make CFLAGS_MODULE=-fno-pic
make INSTALL_MOD_PATH="${DIR}/out" modules_install

# Module list
# ==========================================

MODULES=(
  'probes/lttng-kretprobes'
  'probes/lttng-kprobes'
  'lib/lttng-lib-ring-buffer'
  'lttng-statedump' 
  'lttng-tracer' 

  'probes/lttng-types'
  'probes/lttng-probe-timer' 
  'probes/lttng-probe-statedump' 
  'probes/lttng-probe-signal' 
  'probes/lttng-probe-sched' 
  'probes/lttng-probe-lttng' 
  'probes/lttng-probe-irq' 
  'probes/lttng-probe-block' 
  'probes/lttng-probe-asoc'
  'probes/lttng-probe-compaction'
  'probes/lttng-probe-ext3'
  'probes/lttng-probe-ext4'
  'probes/lttng-probe-gpio'
  'probes/lttng-probe-jbd'
  'probes/lttng-probe-jbd2'
  'probes/lttng-probe-kmem'
  'probes/lttng-probe-module'
  'probes/lttng-probe-napi'
  'probes/lttng-probe-net'
  'probes/lttng-probe-power'
  'probes/lttng-probe-regulator'
  'probes/lttng-probe-scsi'
  'probes/lttng-probe-skb'
  'probes/lttng-probe-sock'
  'probes/lttng-probe-udp'    
  'probes/lttng-probe-vmscan'
  'probes/lttng-probe-workqueue'
  'probes/lttng-probe-writeback'

  'lttng-ring-buffer-metadata-mmap-client'
  'lttng-ring-buffer-metadata-client'
  'lttng-ring-buffer-client-overwrite'
  'lttng-ring-buffer-client-discard'
  'lttng-ring-buffer-client-mmap-discard'

  'This-is-not-a-module'
  'This-is-fuck-you-bash'
)
sleep 1000
# Make sure directory for modules exists
# ==========================================

adb shell rm -rf $REMOTE_INSTALL_PATH
adb shell mkdir -p $REMOTE_INSTALL_PATH

# Unload modules
# ==========================================

echo ${MODULES[@]} | tac -s' ' | while read -d' ' module
do
  echo "Unloading : $module"
  adb shell su -c "rmmod $REMOTE_INSTALL_PATH/$module"
done

echo '=========================================='

# Transfer modules
# ==========================================

adb push ${DIR}/out/lib/modules/$KERNEL_VERMAGIC/extra/ $REMOTE_INSTALL_PATH 


# Load modules 
# ==========================================

for module in "${MODULES[@]}"
do
  echo "Loading probes/${module}"
  adb shell su -c "insmod $REMOTE_INSTALL_PATH/${module}.ko"
done
