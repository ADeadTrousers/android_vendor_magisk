# AOSP Integration for Magisk

## Introduction

Magisk is a suite of open source tools for customizing Android, supporting devices higher than Android 4.2. It covers fundamental parts of Android customization: root, boot scripts, SELinux patches, AVB2.0 / dm-verity / forceencrypt removals etc.

It was created by and is maintained by John Wo.
For the latest release always check [the GitHub Releases of Magisk](https://github.com/topjohnwu/Magisk/releases)

The aim of this repository is simply to integrate Magisk into the build process of AOSP.

## Workflow

1. Extract `magisk.apk` from the archive. This is needed to have a source file the AOSP build process can use.
2. Everything else needs to be performed at the end of the build process (Work in progress)
3. Extract the update survival script `addon.d.sh` as `99-magisk.sh` into the `/system/addon.d` folder and set the permissions to `755`.
4. Extract `magiskboot` and `magiskinit` for the host architecture into the `Magik_intermediates` folder and set the permissions to `755`. These are the filese needed for modifying the boot image.
5. Run `magiskinit -x magisk magisk` to extract the magisk binary from the init command.
6. Extract `magiskinit` for the target architecture into the `Magik_intermediates` folder. This is the one that is actually put into the boot image.
7. Extract `boot_patch.sh` and `util_functions.sh` into the `Magik_intermediates` folder and set the permissions to `755`. These are the script files that will modify the boot image.
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
    MagiskManager
```

## Special Thanks To

- [John Wo](https://github.com/topjohnwu) for creating Magisk.
- [Geofferey Eakins](https://github.com/Geofferey) whom I got this idea from.
