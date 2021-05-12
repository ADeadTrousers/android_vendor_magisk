# AOSP Integration for Magisk

## Introduction

Magisk is a suite of open source tools for customizing Android, supporting devices higher than Android 4.2. It covers fundamental parts of Android customization: root, boot scripts, SELinux patches, AVB2.0 / dm-verity / forceencrypt removals etc.

It was created by and is maintained by John Wo.
For the latest release always check [the GitHub Releases of Magisk](https://github.com/topjohnwu/Magisk/releases)

The aim of this repository is simply to integrate Magisk into the build process of AOSP.

## Workflow

1. Extract `addon.d.sh` from the archive. This is needed to have a source file the AOSP build process can use. This is the Magisk addon survival script and will later be copied to `system/addon.d/99-magisk.sh`.
2. Everything else needs to be performed at the end of the build process (Work in progress)
3. Extract `magiskboot` for the host architecture into the `intermediates` folder and set the permissions to `755`. This is the file needed for modifying the boot image.
5. Extract `magiskinit`, `magisk32` and `magisk64` for the target architecture into the `intermediates` folder. These are the ones that are actually put into the boot image.
7. Extract `boot_patch.sh` and `util_functions.sh` into the `intermediates` folder and set the permissions to `755`. These are the script files that will modify the boot image.
8. The shebang (#!) from `boot_patch.sh` needs to be remove otherwise the script won't run.
9. Also the script needs the correct output device so `export OUTFD="1"` is being set.
10. Now the script can be executed with `boot_patch.sh boot.img`.
11. The file `new-boot.img` is being created and then copied back as `boot.img` into the out directory.

## Integration

Add the following to the manifest-tag in your `roomservice.xml`

```xml
  <project name="ADeadTrousers/android_vendor_magisk" path="vendor/magisk" remote="github" revision="master" />
```

Add the following to your device.mk

```
PRODUCT_PACKAGES += \
    99-magisk
```

## Known issues

1) Currently I can't find any way to schedule the build AFTER the building of boot.img. So you've to run your build twice in order get magisk integrated for sure.
2) The modified boot.img doesn't get automatically integrated into the final zip. Maybe the packing process uses the information from the "intermediates" folder. 

## Special Thanks To

- [John Wo](https://github.com/topjohnwu) for creating Magisk.
- [Geofferey Eakins](https://github.com/Geofferey) whom I got this idea from.
