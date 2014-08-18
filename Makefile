CWD = $(shell pwd)

include env.mk

ifdef ANDROID_TREE
popt:	CPPFLAGS += -DHAVE_STRERROR
uuid:	CPPFLAGS += -undefHAVE_SYS_UN_H
endif

tools: LDFLAGS += -lxml2

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

popt:
	cd popt; \
	autoreconf -i; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make install;

ifdef DO_NOT_USE
libxml:
	cp -r ${SYSROOT}/SHARED_LIBRARIES/libxml2/include/libxml ${INSTALL_PATH}/${TARGET_INSTALL_PATH}/include/
	cd ${ANDROID_BUILD_TOP}/external/icu4c/common && find -name '*.h' | cpio -pdm ${INSTALL_PATH}/${TARGET_INSTALL_PATH}/include
else
libxml:
	cd libxml2; \
	autoreconf -i; \
	./configure --without-lzma --enable-shared --enable-static ${CONFIGURE_OPTIONS}; \
	make libxml2.la; \
	cp .libs/libxml2.a ${INSTALL_PATH}/${TARGET_INSTALL_PATH}/lib/;
	cd libxml2/.libs && find -name 'libxml2.so*' | cpio -pdm ${INSTALL_PATH}${TARGET_INSTALL_PATH}/lib/

endif

ifdef ANDROID_TREE
uuid:
	cp ${SYSROOT}/SHARED_LIBRARIES/libext2_uuid_intermediates/LINKED/libext2_uuid.so ${INSTALL_PATH}/${TARGET_INSTALL_PATH}/lib/libuuid.so

else
uuid:
	cd src/e2fsprogs; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	cd lib/uuid; \
	make; \
	make install;

endif

urcu-mk:
	cd userspace-rcu ;\
	./bootstrap; \
	./configure $(CONFIGURE_OPTIONS); \
	make Android.mk;
urcu:
	cd userspace-rcu ; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS}; \
	make; \
	make install;

tools-mk:
	cd lttng-tools; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS} --disable-lttng-ust --program-prefix='' --with-lttng-rundir=/data/lttng/var/run ; \
	make Android.mk; \

tools:
	cd lttng-tools; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS} --program-prefix='' --with-lttng-system-rundir=/data/lttng/var/run --with-xml-prefix=${INSTALL_PATH}${TARGET_INSTALL_PATH} ;  \
	make; \
	make DESTDIR=${INSTALL_PATH} install;
	#--disable-lttng-ust ; \

ust: CPPFLAGS += -fPIC
ust:
	cd lttng-ust; \
	./bootstrap; \
	./configure ${CONFIGURE_OPTIONS} --disable-static --libdir=${LIBDIR} --program-prefix='' --with-lttng-system-rundir=/data/lttng/var/run ; \
	make clean; \
	make; \
	make DESTDIR=${INSTALL_PATH} install; \
	rm -rf ${INSTALL_PATH}/${LIBDIR}/pkgconfig; \
	mv ${INSTALL_PATH}/${LIBDIR}/* ${LIBDIR}/; \
	rm -rf ${INSTALL_PATH}/tmp

# 	$(CWD)/scripts/update-libdir.sh ${INSTALL_PATH}${TARGET_INSTALL_PATH}/lib .; \
# 	$(CWD)/scripts/update-libdir.sh ${INSTALL_PATH}${TARGET_INSTALL_PATH}/lib; \
#

modules: LDFLAGS =
modules: CPPFLAGS =
modules: CFLAGS =
modules:
	cd lttng-modules; \
	make ; #CFLAGS_MODULE=-fno-pic;
	#make modules_install INSTALL_MOD_PATH=${INSTALL_PATH};

load-modules:
	./scripts/modules load

unload-modules:
	./scripts/modules unload

kernel: LDFLAGS =
kernel: CPPFLAGS =
kernel:
	cd ${KERNELDIR}; \
	make ${KERNEL_CONFIG}; \
	make

trace:
	adb push scripts/trace-ust.sh /data/local/tmp/
	adb shell "su -c \"sh -v /data/local/tmp/trace-ust.sh\""

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
	adb shell "su -c \"tar -x -f ${PACKAGE_PUSH_PATH} -C /\""

remount:
	adb shell "su -c \"mount -o rw,remount /data\""

# remove default directories for SDK/NDK
# FIXME: complete cleanup
clean:
	for D in src/*; do [ -d "$${D}" ] && cd $$D; make clean; done

.PHONY: clean

complete-clean: clean
	rm -rf ndk/
	rm -rf sdk/

.PHONY: complete-clean
.PHONY: popt
