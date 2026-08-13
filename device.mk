# device.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)

LOCAL_PATH := device/samsung/j3y17lte

$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# gps_us_supl.mk removed: not part of the omni minimal manifest (so
# repo sync never fetches it), and TWRP recovery has no use for
# SUPL/location config regardless.

$(call inherit-product-if-exists, vendor/samsung/j3y17lte/j3y17lte-vendor.mk)

DEVICE_PACKAGE_OVERLAYS += device/samsung/j3y17lte/overlay

# Recovery ramdisk files below are pulled straight from the extracted
# working ramdisk, not reconstructed. Exception: default.prop (if you add
# it) needs ro.omni.* and ro.build.version.release=6.0.1 stripped first —
# stale branding from the old source tree, not functionally required.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/etc/recovery.fstab:recovery/root/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery/root/init.recovery.hlthchrg.rc:recovery/root/init.recovery.hlthchrg.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.service.rc:recovery/root/init.recovery.service.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.usb.rc:recovery/root/init.recovery.usb.rc

ifeq ($(TARGET_PREBUILT_KERNEL),)
	LOCAL_KERNEL := $(LOCAL_PATH)/kernel
else
	LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel

# PRODUCT_BOARD identifies the SoC platform to the build system.
PRODUCT_BOARD := universal7570

# embedded.mk, not full.mk: full.mk pulls in the whole system-partition
# package/app set, which this recovery-only build doesn't need and which
# was the actual cause of a "system/bin/linker missing" ninja failure —
# it changes how core bionic/linker targets get scheduled in a way that
# broke the recovery link step. Don't switch back without reproducing
# that failure first.
$(call inherit-product-if-exists, $(SRC_TARGET_DIR)/product/embedded.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

PRODUCT_PACKAGES += \
    charger \
    charger_res_images
