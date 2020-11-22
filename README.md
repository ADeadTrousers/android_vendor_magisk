# android_vendor_magisk

This repo only copies magisinit to PRODUCT_OUT
Additional changes to build/core/Make are required

~~https://github.com/Geofferey/omni_android_build/commit/8fc7d8f3cd8e0c09418047264475abc652439bdd~~
https://github.com/ADeadTrousers/android_device_Unihertz_Atom_XL/blob/master/patch/build_make/0002-build-add-rule-to-include-Magisk-in-builds.patch

This is a fork of Geofferey's original repository but tries to offer the latest Magisk version.
For convinience it also uses the original Magisk-release zip-files instead of the unpacked files itself.
This way it's easier for the common device maintainer to update their included Magisk version.
