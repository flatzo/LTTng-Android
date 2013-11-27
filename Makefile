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
	count=`git submodule status | wc -l`; \
	if [ "$$count" -lt "4" ]; then \
	git submodule init; \
	git submodule update; \
	fi

popt: download-dependencies
	cd deps/popt; \
	autoreconf -i; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make DESTDIR=${INSTALL_PATH} install;

uuid: download-dependencies
	cd deps/e2fsprogs; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	cd lib/uuid; \
	make; \
	make DESTDIR=${INSTALL_PATH} install;

urcu: download-dependencies
	cd lttng/liburcu; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make DESTDIR=${INSTALL_PATH} install;

tools: popt uuid urcu
	cd lttng/tools; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS} --disable-lttng-ust --program-prefix='' --with-lttng-rundir=/data/lttng/var/run ; \
	make; \
	make DESTDIR=${INSTALL_PATH} install;

modules: kernel
	cd lttng/modules; \
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
	adb shell "su -c \"mkdir ${TARGET_INSTALL_PATH}\""
	adb shell "su -c \"tar -x -f ${PACKAGE_PUSH_PATH} -C /\""

# remove default directories for SDK/NDK
# FIXME: complete cleanup
clean:
	for D in src/*; do [ -d "$${D}" ] && cd $$D; make clean; done

.PHONY: clean

complete-clean: clean
	rm -rf ndk/
	rm -rf sdk/

.PHONY: complete-clean
