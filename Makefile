CWD = $(shell pwd)

include env.mk

all: tools 

download-dependencies:
	git submodule init
	git submodule update

popt: download-dependencies
	@echo ${HOST}
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
	./configure ${CONFIGURE_OPTIONS} --disable-lttng-ust --program-prefix=''; \
	make; \
	make install;

package:
	cd ${INSTALL_PATH}; \
	tar -cf ../lttng-android.tar *

push-package:
	adb push /tmp/lttng-android.tar ${PACKAGE_PUSH_PATH} 
	adb shell "su -c tar -xf ${PACKAGE_PUSH_PATH} -C ${REMOTE_INSTALL_PATH}"

