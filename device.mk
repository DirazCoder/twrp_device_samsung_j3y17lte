# device.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# Same provenance note as BoardConfig.mk in this folder: this is a skeleton
# written to match what was extracted from a real working recovery.img, not
# an original source file. Sections are marked VERIFIED or UNVERIFIED the
# same way. Treat UNVERIFIED lines as "shaped correctly, not fact-checked."

LOCAL_PATH := device/samsung/j3y17lte

# ------------------------------------------------------------------------
# Recovery ramdisk — VERIFIED. Point this PRODUCT_COPY_FILES-style list (or
# your recovery root sync mechanism, depending on build system in use) at
# the extracted files in this repo's recovery_root/. These are known-good,
# not reconstructed:
#   recovery_root/etc/recovery.fstab
#   recovery_root/init.rc
#   recovery_root/init.recovery.hlthchrg.rc
#   recovery_root/init.recovery.service.rc
#   recovery_root/init.recovery.usb.rc
#   recovery_root/default.prop         <- strip/replace ro.omni.* and
#                                          ro.build.version.release=6.0.1
#                                          lines before using in a new
#                                          build; those are stale branding
#                                          from the old source tree, not
#                                          functionally required.
#   recovery_root/sepolicy
#   recovery_root/file_contexts
#   recovery_root/property_contexts
#   recovery_root/seapp_contexts
#   recovery_root/service_contexts
# ------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery_root/etc/recovery.fstab:recovery/root/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery_root/init.recovery.hlthchrg.rc:recovery/root/init.recovery.hlthchrg.rc \
    $(LOCAL_PATH)/recovery_root/init.recovery.service.rc:recovery/root/init.recovery.service.rc \
    $(LOCAL_PATH)/recovery_root/init.recovery.usb.rc:recovery/root/init.recovery.usb.rc

# ------------------------------------------------------------------------
# Product identity — VERIFIED, pulled directly from default.prop of the
# working image. Reuse the device/board/model strings; do NOT reuse the
# ro.build.version.release/ro.omni.* values (stale, see note above).
# ------------------------------------------------------------------------
PRODUCT_DEVICE   := j3y17lte
PRODUCT_BRAND    := samsung
PRODUCT_MODEL    := SM-J330FN
PRODUCT_MANUFACTURER := samsung
PRODUCT_BOARD    := universal7570

# ------------------------------------------------------------------------
# UNVERIFIED / TEMPLATE below this line — standard boilerplate you'd need
# in any device.mk, not something a recovery image teardown can confirm.
# ------------------------------------------------------------------------
$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)

PRODUCT_PACKAGES += \
    charger \
    charger_res_images

# Kernel — see BoardConfig.mk: use the extracted prebuilt `kernel` file
# from this repo's root (verified working, ARM64) since no kernel source
# was recoverable from the compiled image.
