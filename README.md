LTTng-Android
=============

This project aims to facilitate the compilation of LTTng for Android platform. 
Makefiles are provided in order to build dependencies, difference LTTng projects 
and package/install it on your Android device.

Quick start
-----------

In order to compile every LTTng package that have been ported at the moment : 

### AOSP
1. Download android source, refer to [AOSP](https://source.android.com/source/initializing.html)
2. Fill the file named ``fill_out.mk`` with required informations. You can leave out kernel and ndk related stuff.
3. Build dependencies in Android tree using by changing the current working directory the following projects and using ``mm`` to build the Android module
 * libext2/uuid
4. Run the following commands

```bash
git clone git://github.com/flatzo/LTTng-Android.git
make download-dependencies # Download the source code requried to build dependencies
make popt uuid libxml urcu
make ust # Might have to run twice
make tools
make package
make push-package
```


Building from AOSP tree
-----------------------

### Build dependencies

* liboprofile/libpopt
* libxml2
  * Add to Android.mk ``LOCAL_CLFAGS += -DLIBXML_SCHEMAS_ENABLED``
