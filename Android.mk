LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := Magisk
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := FAKE

ifndef $(MAGISK_VERSION)
MAGISK_VERSION := 21.4
endif
MAGISK_ARCHIVE := Magisk-v$(MAGISK_VERSION).zip

LOCAL_SRC_FILES    := $(MAGISK_ARCHIVE)

ifeq ($(TARGET_ARCH), arm)
LOCAL_POST_INSTALL_CMD := unzip -p Magisk arm/magiskinit > magiskinit; \
  unzip -p Magisk arm/magiskboot > magiskboot;
else ifeq ($(TARGET_ARCH), arm64)
LOCAL_POST_INSTALL_CMD := unzip -p Magisk arm/magiskinit64 > magiskinit; \
  unzip -p Magisk arm/magiskboot > magiskboot;
else ifeq ($(TARGET_ARCH), x86)
LOCAL_POST_INSTALL_CMD := unzip -p Magisk x86/magiskinit > magiskinit; \
  unzip -p Magisk x86/magiskboot > magiskboot;
else ifeq ($(TARGET_ARCH), x86_64)
LOCAL_POST_INSTALL_CMD := unzip -p Magisk x86/magiskinit64 > magiskinit; \
  unzip -p Magisk x86/magiskboot > magiskboot;
endif

LOCAL_POST_INSTALL_CMD += unzip -p Magisk common/addon.d.sh > $(TARGET_COPY_OUT_SYSTEM)/addon.d/99-magisk.sh; \
  unzip -p Magisk common/boot_patch.sh > boot_patch.sh; \
  unzip -p Magisk common/util_functions.sh > util_functions.sh; \
  boot_patch.sh $(PRODUCT_OUT)/boot.img
include $(BUILD_PREBUILT)
