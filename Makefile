CWD = $(shell pwd)

include env.mk

all: tools modules

download-ndk:	${NDK}
${NDK}:
	mkdir -p "${NDK_BASE}"
	wget -O - "${NDK_URL}" | bzip2 -d | tar -C ${NDK_BASE} -x
	@test -d ${NDK} || { echo "Error: directory ${NDK} doesn't exist after download"; exit 1; }

download-sdk:	${SDK}
${SDK}:
	mkdir -p "${SDK_BASE}"
	wget -O - "${SDK_URL}" | gzip -d | tar -C ${SDK_BASE} -x
	@test -d ${SDK} || { echo "Error: directory ${SDK} doesn't exist after download"; exit 1; }

download-dependencies:
	git submodule init
	git submodule update

popt: download-dependencies
	cd src/popt; \
	autoreconf -i; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make install;

uuid: download-dependencies
	cd src/e2fsprogs; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	cd lib/uuid; \
	make; \
	make install;

urcu: download-dependencies
	cd src/urcu; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make install;

tools: popt uuid urcu
	cd src/lttng-tools; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS} --disable-lttng-ust --program-prefix='' --with-lttng-rundir=/data/lttng/var/run ; \
	make; \
	make install;

modules: kernel
	cd src/modules; \
	make CFLAGS_MODULE=-fno-pic; \
	make modules_install INSTALL_MOD_PATH=${INSTALL_PATH};

load-modules:
	./scripts/modules load

unload-modules:
	./scripts/modules unload

kernel:
	cd ${KERNELDIR}; \
	make ${KERNEL_CONFIG}; \
	make 

get-kernel-commit:
	cd /tmp; \
	git clone https://android.googlesource.com/device/${VENDOR}/${DEVICE}; \
	cd ${DEVICE}; \
	git log --max-count=1 kernel;

package:
	cd ${INSTALL_PATH}; \
	tar -cf ../lttng-android.tar *

push-package:
	adb push /tmp/lttng-android.tar ${PACKAGE_PUSH_PATH} 
	adb shell "su -c \"mkdir -p ${TARGET_INSTALL_PATH}\""
	adb shell "su -c \"tar -x -f ${PACKAGE_PUSH_PATH} -C ${TARGET_INSTALL_PATH}\""

# remove default directories for SDK/NDK
# FIXME: complete cleanup
clean:
	rm -rf ndk/
	rm -rf sdk/

.PHONY: clean
