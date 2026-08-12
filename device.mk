# device.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# PROVENANCE: see BoardConfig.mk in this folder for the full [DEVICE] /
# [REFTREE] / [TEMPLATE] tagging scheme.
#
# CORRECTION LOG: this file went embedded.mk -> full.mk -> embedded.mk.
# full.mk was tried on the theory that embedded.mk was "too minimal" for
# a phone build, but full.mk is the whole-system product base and it's
# what actually broke the recovery link step (system/bin/linker never
# got a build rule — see the note at the embedded.mk inherit below for
# the mechanism). embedded.mk is the base every working omni/TWRP device
# tree inherits; that was correct in the first place. Don't re-"fix"
# this back to full.mk without reproducing the actual failure it was
# meant to solve first.

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

# CORRECTION (reverted): full.mk pulls in the entire system-partition
# package/app set, which this recovery-only build doesn't need and which
# was the actual cause of the "system/bin/linker missing, needed by
# libbmlutils_intermediates/teamwin" ninja failure — full.mk changes how
# core bionic/linker targets get scheduled in a way that broke the
# recovery link step. embedded.mk is the base every working omni/TWRP
# device tree actually inherits (see minimal-manifest-twrp's own
# "how to create a device tree" reference); switching back to it.
$(call inherit-product-if-exists, $(SRC_TARGET_DIR)/product/embedded.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0   # [REFTREE]
PRODUCT_NAME  := omni_j3y17lte
PRODUCT_DEVICE := j3y17lte

PRODUCT_PACKAGES += \
    charger \
    charger_res_images
