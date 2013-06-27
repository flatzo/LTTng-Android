LTTng-Android
=============

This project aims to facilitate the compilation of LTTng for Android platform. 
Makefiles are provided in order to build dependencies, difference LTTng projects 
and package/install it on your Android device.

Quick start
-----------

In order to compile every LTTng package that have been ported at the moment : 

1. Download Android [SDK](http://developer.android.com/sdk/index.html) ```make download-sdk``` and [NDK](http://developer.android.com/tools/sdk/ndk/index.html) ```make download-ndk```. If you already have those, skip this step and fill SDK and NDK variables in ```fille_out.mk```. 
2. Fill the file named ```fill_out.mk``` with your own informations
3. Run the following commands

```bash
git clone git://github.com/flatzo/LTTng-Android.git
make            
make package
make push-package
```
