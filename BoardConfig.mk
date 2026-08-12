# BoardConfig.mk — Samsung Galaxy J3 2017 (j3y17lte)
#
# Sourcing, plainly:
#   - Values marked CONFIRMED were read directly off recovery_orig.img
#     (bootimg header via `file`, ramdisk contents via default.prop /
#     recovery.fstab). That image's own fingerprint identifies it as
#     SM-J330FN, not J330F — see device.mk for the model-string note.
#   - "J3 Pro" (joephyu/android_device_samsung_j3y17lte, this tree's
#     original lineage) is Samsung's own marketing name for this same
#     SM-J330 hardware family in some regions — confirmed via Samsung's
#     official firmware metadata, which lists device=j3y17lte,
#     board=universal7570 for a real SM-J330FN unit. So J330F/FN/G/Pro
#     are the same board under different regional badges, not separate
#     devices — this is a real cross-check, not an assumption.
#   - Values marked ASSUMED are standard for this board/SoC generation
#     but have no direct confirmation in this repo. Treat them as a
#     starting point, not a verified fact — check against a build or a
#     kernel defconfig before relying on them.
#   - Nothing in this file has been confirmed by flashing/booting a
#     J330F specifically. If you do that, come back and update this header.

DEVICE_PATH := device/samsung/j3y17lte

USE_CAMERA_STUB := true

# Boot image geometry — CONFIRMED via `file recovery_orig.img`:
#   "Android bootimg, kernel (0x10008000), ramdisk (0x11000000), page size: 2048"
BOARD_KERNEL_BASE     := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE  := # Exynos doesn't take cmdline arguments from boot image
BOARD_MKBOOTIMG_ARGS  := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --board SRPQE04B000RU
# --board string: ASSUMED, carried from prior tree lineage, not independently
# re-derived here. Wrong value here means mkbootimg output won't be accepted
# by the bootloader, so verify before relying on it.

# Architecture — CONFIRMED via default.prop: ro.zygote=zygote32,
# ro.build.version.sdk=23 (Android 6.0.1), consistent with a 32-bit-only
# userspace target.
TARGET_ARCH                := arm
TARGET_ARCH_VARIANT         := armv7-a-neon
TARGET_CPU_ABI              := armeabi-v7a
TARGET_CPU_ABI2             := armeabi
TARGET_CPU_ABI_LIST_32_BIT  := armeabi-v7a,armeabi
TARGET_CPU_VARIANT          := cortex-a15
TARGET_CPU_SMP               := true

# Platform — CONFIRMED via default.prop / recovery.fstab paths
# (ro.product.board / block device paths both reference universal7570).
TARGET_BOARD_PLATFORM         := exynos5
TARGET_BOARD_PLATFORM_GPU     := mali-T720   # ASSUMED — standard for Exynos 7570, not read off this image
TARGET_BOOTLOADER_BOARD_NAME  := universal7570
TARGET_NO_BOOTLOADER          := true

# Kernel — using prebuilt by default since no kernel source is synced
# into this tree. If you sync Samsung's GPL kernel source for J330F,
# point TARGET_KERNEL_SOURCE/CONFIG at it and switch off the prebuilt
# path below; do not assume the defconfig name until you've confirmed
# it against the actual GPL source drop for J330F (not J330FN).
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/kernel
TARGET_PREBUILT_DTB    := $(DEVICE_PATH)/dt.img

# Partitions — boot/recovery sizes CONFIRMED via recovery_orig.img's own
# bootimg header math (page size * page count). system/cache/userdata
# sizes are ASSUMED (standard for this device class, not independently
# measured from any file in this repo).
BOARD_BOOTIMAGE_PARTITION_SIZE     := 0x2000000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x2600000
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 0xAC000000
BOARD_CACHEIMAGE_PARTITION_SIZE    := 0xC800000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 0x2DE000000
BOARD_SYSTEMIMAGE_PARTITION_TYPE   := ext4
BOARD_USERDATAIMAGE_PARTITION_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_TYPE    := ext4
BOARD_FLASH_BLOCK_SIZE             := 131072

BOARD_HAS_LARGE_FILESYSTEM  := true
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_HAS_SDCARD_INTERNAL   := true
BOARD_USES_MMCUTILS         := true
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_HAS_NO_SELECT_BUTTON  := true
BOARD_SUPPRESS_EMMC_WIPE    := true
TARGET_USERIMAGES_USE_EXT4  := true
TARGET_USERIMAGES_USE_F2FS  := true

BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/bootimg.mk

# recovery.fstab — CONFIRMED, this is the fstab extracted directly from
# recovery_orig.img's ramdisk, with two corrections since made against
# it: /data now carries flags=encryptable=footer (present in the real
# ramdisk fstab, this device uses footer-based FDE), and /recovery now
# carries a display/backup flag to match. See git history for the diff.
TARGET_RECOVERY_FSTAB           := $(DEVICE_PATH)/recovery/root/etc/recovery.fstab
TW_INCLUDE_CRYPTO               := true
TW_INTERNAL_STORAGE_PATH        := "/data/media"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH        := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
TW_DEFAULT_EXTERNAL_STORAGE     := true
RECOVERY_SDCARD_ON_DATA         := true

# Display — CONFIRMED via TWRP UI theme reference in the extracted
# ramdisk (twres/portrait.xml assumes this resolution).
TW_THEME                     := portrait_hdpi
TARGET_SCREEN_WIDTH          := 720
TARGET_SCREEN_HEIGHT         := 1280
DEVICE_RESOLUTION            := 720x1280
DEVICE_SCREEN_WIDTH          := 720
DEVICE_SCREEN_HEIGHT         := 1280
TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"

# Misc TWRP flags
TARGET_USES_LOGD    := true
TWRP_INCLUDE_LOGCAT := true

# STILL OPEN, genuinely:
#   - Everything marked ASSUMED above.
#   - Whether this actually boots on a real J330F (only ever confirmed
#     against a J330FN-fingerprinted image).
#   - Kernel source / defconfig for J330F specifically.
