LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := MagiskManager
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := $(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

ifndef $(MAGISK_VERSION)
  MAGISK_VERSION := 21.4
endif

MY_MAGISK_INTERMEDIATES := $(TARGET_OUT_INTERMEDIATES)/$(LOCAL_MODULE_CLASS)/$(LOCAL_MODULE)_intermediates
MY_MAGISK_ARCHIVE := $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).zip
MY_MAGISK_SIGNING_KEY := build/make/target/product/security/verity

MY_MAGISK_SOURCE_IMAGE := $(MY_MAGISK_INTERMEDIATES)/new-boot.img
MY_MAGISK_SOURCE_MANAGER := common/magisk.apk
MY_MAGISK_SOURCE_ADDON := common/addon.d.sh
MY_MAGISK_SOURCE_PATCH := common/boot_patch.sh
MY_MAGISK_SOURCE_FUNCTIONS := common/util_functions.sh
ifeq ($(TARGET_ARCH), arm)
  MY_MAGISK_SOURCE_INIT := arm/magiskinit
else ifeq ($(TARGET_ARCH), arm64)
  MY_MAGISK_SOURCE_INIT := arm/magiskinit64
else ifeq ($(TARGET_ARCH), x86)
  MY_MAGISK_SOURCE_INIT := x86/magiskinit
else ifeq ($(TARGET_ARCH), x86_64)
  MY_MAGISK_SOURCE_INIT := x86/magiskinit64
else
  $(error Target architecture not supported: $(TARGET_ARCH))
endif

ifeq ($(HOST_ARCH), arm)
  MY_MAGISK_SOURCE_HOST := arm/magiskinit
  MY_MAGISK_SOURCE_BOOT := arm/magiskboot
else ifeq ($(HOST_ARCH), arm64)
  MY_MAGISK_SOURCE_HOST := arm/magiskinit64
  MY_MAGISK_SOURCE_BOOT := arm/magiskboot
else ifeq ($(HOST_ARCH), x86)
  MY_MAGISK_SOURCE_HOST := x86/magiskinit
  MY_MAGISK_SOURCE_BOOT := x86/magiskboot
else ifeq ($(HOST_ARCH), x86_64)
  MY_MAGISK_SOURCE_HOST := x86/magiskinit64
  MY_MAGISK_SOURCE_BOOT := x86/magiskboot
else
  $(error Host architecture not supported: $(TARGET_ARCH))
endif

MY_MAGISK_TARGET_IMAGE := $(PRODUCT_OUT)/boot.img
MY_MAGISK_TARGET_MANAGER := $(LOCAL_PATH)/$(LOCAL_SRC_FILES)
MY_MAGISK_TARGET_ADDON := $(PRODUCT_OUT)/system/addon.d/99-magisk.sh
MY_MAGISK_TARGET_PATCH := $(MY_MAGISK_INTERMEDIATES)/boot_patch.sh
MY_MAGISK_TARGET_FUNCTIONS := $(MY_MAGISK_INTERMEDIATES)/util_functions.sh
MY_MAGISK_TARGET_BOOT := $(MY_MAGISK_INTERMEDIATES)/magiskboot
MY_MAGISK_TARGET_INIT := $(MY_MAGISK_INTERMEDIATES)/magiskinit
MY_MAGISK_TARGET_MAGISK := $(MY_MAGISK_INTERMEDIATES)/magisk

$(shell unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_MANAGER) > $(MY_MAGISK_TARGET_MANAGER) 2>/dev/null)

LOCAL_POST_INSTALL_CMD := \
  rm -f $(MY_MAGISK_TARGET_MANAGER) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_ADDON) > $(MY_MAGISK_TARGET_ADDON) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_PATCH) > $(MY_MAGISK_TARGET_PATCH); \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_FUNCTIONS) > $(MY_MAGISK_TARGET_FUNCTIONS) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_BOOT) > $(MY_MAGISK_TARGET_BOOT) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_HOST) > $(MY_MAGISK_TARGET_INIT) && \
  chmod 755 $(MY_MAGISK_TARGET_INIT) && \
  $(MY_MAGISK_TARGET_INIT) -x magisk $(MY_MAGISK_TARGET_MAGISK) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_INIT) > $(MY_MAGISK_TARGET_INIT) && \
  sed -i '1d' $(MY_MAGISK_TARGET_PATCH) && \
  chmod 755 $(MY_MAGISK_TARGET_ADDON) && \
  chmod 755 $(MY_MAGISK_TARGET_PATCH) && \
  export OUTFD="1" && \
  $(MY_MAGISK_TARGET_PATCH) ../../../boot.img && \
  $(BOOT_SIGNER) /boot $(MY_MAGISK_SOURCE_IMAGE) $(MY_MAGISK_SIGNING_KEY).pk8 $(MY_MAGISK_SIGNING_KEY).x509.pem $(MY_MAGISK_SOURCE_IMAGE) && \
  $(AVBTOOL) add_hash_footer --image $(MY_MAGISK_SOURCE_IMAGE) --partition_size $(BOARD_BOOTIMAGE_PARTITION_SIZE) --partition_name boot --prop com.android.build.boot.os_version:10 && \
  mv -f $(MY_MAGISK_SOURCE_IMAGE) $(MY_MAGISK_TARGET_IMAGE)

include $(BUILD_PREBUILT)
