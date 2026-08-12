# device.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# PROVENANCE: see BoardConfig.mk in this folder for the full [DEVICE] /
# [REFTREE] / [TEMPLATE] tagging scheme.
#
# CORRECTION LOG: this file previously inherited embedded.mk, a minimal
# product base meant for non-phone targets (TVs, wearables). The proven
# joephyu tree inherits build/target/product/full.mk plus language and
# GPS config instead — corrected below. embedded.mk missing standard
# phone-product packages/config is a plausible source of confusing
# lunch/build failures that would have looked like a device-tree bug.

LOCAL_PATH := device/samsung/j3y17lte

$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)   # [REFTREE]

# gps_us_supl.mk removed: not part of the omni minimal manifest (so
# repo sync never fetches it), and TWRP recovery has no use for
# SUPL/location config regardless.

$(call inherit-product-if-exists, vendor/samsung/j3y17lte/j3y17lte-vendor.mk)   # [REFTREE]

DEVICE_PACKAGE_OVERLAYS += device/samsung/j3y17lte/overlay   # [REFTREE]

# ------------------------------------------------------------------------
# Recovery ramdisk — [DEVICE] VERIFIED. These are known-good files pulled
# straight from the extracted working ramdisk, not reconstructed:
#   recovery_root/etc/recovery.fstab
#   recovery_root/init.recovery.hlthchrg.rc
#   recovery_root/init.recovery.service.rc
#   recovery_root/init.recovery.usb.rc
#   recovery_root/default.prop         <- strip/replace ro.omni.* and
#                                          ro.build.version.release=6.0.1
#                                          before using; stale branding
#                                          from the old source tree, not
#                                          functionally required.
# ------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery_root/etc/recovery.fstab:recovery/root/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery_root/init.recovery.hlthchrg.rc:recovery/root/init.recovery.hlthchrg.rc \
    $(LOCAL_PATH)/recovery_root/init.recovery.service.rc:recovery/root/init.recovery.service.rc \
    $(LOCAL_PATH)/recovery_root/init.recovery.usb.rc:recovery/root/init.recovery.usb.rc

ifeq ($(TARGET_PREBUILT_KERNEL),)
	LOCAL_KERNEL := $(LOCAL_PATH)/kernel
else
	LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel

# ------------------------------------------------------------------------
# Product identity.
#
# NOTE: the recovery.img this tree was originally reverse-engineered from
# (recovery_orig.img, ro.build.fingerprint in default.prop) reports
# PRODUCT_MODEL=SM-J330FN, not SM-J330F. J330F/FN/G are the same board
# (universal7570) and near-identical hardware, so this tree should still
# build and boot fine on a J330F, but the model string below has been
# corrected to match the actual target device rather than silently
# carrying over the FN value from that source image.
# ------------------------------------------------------------------------
PRODUCT_DEVICE       := j3y17lte
PRODUCT_BRAND        := samsung
PRODUCT_MODEL        := SM-J330F
PRODUCT_MANUFACTURER := samsung
PRODUCT_BOARD        := universal7570

# [REFTREE] — standard product base for a phone recovery target, replaces
# the previous (incorrect) embedded.mk inheritance.
$(call inherit-product, build/target/product/full.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0   # [REFTREE]
PRODUCT_NAME  := full_j3y17lte
PRODUCT_DEVICE := j3y17lte

PRODUCT_PACKAGES += \
    charger \
    charger_res_images
