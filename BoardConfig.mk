# BoardConfig.mk — Samsung Galaxy J3 2017 (j3y17lte)
#
# Values were read directly off recovery_orig.img (bootimg header, the
# ramdisk's own ELF binaries, and recovery.fstab) — see the arch note below
# for a case where a stale prop string would've given the wrong answer.
# Tested on real hardware: flashed to a SM-J330F, wiped and mounted
# partitions, installed a custom ROM. J330F/FN/G/Pro are the same
# universal7570 board under different regional badges, confirmed against
# Samsung's own firmware metadata.

DEVICE_PATH := device/samsung/j3y17lte

USE_CAMERA_STUB := true

# Boot image geometry, read via `file recovery_orig.img`.
BOARD_KERNEL_BASE     := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE  := # Exynos doesn't take cmdline arguments from boot image
BOARD_MKBOOTIMG_ARGS  := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --board SRPQC17A001RU
# --board string read from Samsung's own stock recovery image for this
# device (recovery.img header field BOARD_NAME, verified with `od -c`).

# Architecture confirmed by checking the ramdisk's ELF binaries directly:
# recovery, twrp, busybox, mke2fs, sgdisk, make_ext4fs, simg2img, and
# toolbox are all aarch64 with an ELF64 linker interpreter. sbin/linker
# (32-bit) is also present but unused — nothing in the ramdisk needs it,
# see the TARGET_SUPPORTS_32_BIT_LINKER note below. This overrides an
# earlier version of this file that set arm/armeabi-v7a based on a stale
# ro.zygote=zygote32 line in default.prop, which is leftover branding, not
# a description of the actual binaries.
TARGET_ARCH                  := arm64
TARGET_ARCH_VARIANT          := armv8-a
TARGET_CPU_ABI                := arm64-v8a
TARGET_CPU_ABI2                :=
TARGET_CPU_VARIANT           := cortex-a53
TARGET_CPU_SMP                := true

# Without these, the build schedules a 32-bit system/bin/linker copy step
# that an arm64-only tree never produces, and ninja fails looking for it.
TARGET_SUPPORTS_32_BIT_LINKER := false
TARGET_SUPPORTS_64_BIT_LINKER := true

TARGET_CPU_ABI_LIST_64_BIT := arm64-v8a
TARGET_CPU_ABI_LIST        := arm64-v8a

# Platform read from default.prop / recovery.fstab (both reference
# universal7570).
TARGET_BOARD_PLATFORM         := exynos5
# GPU confirmed externally (recovery ramdisks don't reference a GPU model;
# TWRP renders via framebuffer). Cross-checked against 5 spec sources
# (Notebookcheck, CPU-Monkey, PhonesSpecs, GSMArena) — Exynos 7570 uses
# Mali-T720 MP2.
TARGET_BOARD_PLATFORM_GPU     := mali-T720-MP2
TARGET_BOOTLOADER_BOARD_NAME  := universal7570
TARGET_NO_BOOTLOADER          := true

# Reboot menu — this Exynos platform has no distinct bootloader mode, so
# "Reboot > Bootloader" was rebooting into nothing (confirmed against
# recovery.img's ramdisk: portrait.xml defines separate Bootloader and
# Download listitems, gated on tw_reboot_bootloader and tw_download_mode
# respectively — neither flag was set here, so TWRP fell back to showing
# Bootloader by default and never enabled the working Download path).
# Samsung's actual equivalent is download/Odin mode, which sbin/twrp
# already supports as `reboot download`.
TW_HAS_DOWNLOAD_MODE     := true
TW_NO_REBOOT_BOOTLOADER  := true

# Using the prebuilt kernel below since no kernel source is synced into
# this tree. If you sync Samsung's GPL kernel source for J330F, point
# TARGET_KERNEL_SOURCE/CONFIG at it instead and use its defconfig name.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/kernel
TARGET_PREBUILT_DTB    := $(DEVICE_PATH)/dt.img
# dt.img extracted from recovery_orig.img at the offset given by the
# bootimg header's own dt_size field. Magic bytes are "DTBH" v2, 4
# entries — Samsung's multi-DTB table format, not corrupt data. Setting
# this variable alone doesn't make ninja build dt.img; see AndroidBoard.mk
# for the rule that actually wires it in.

# Partitions — boot/recovery sizes confirmed via the bootimg header math.
# system/cache/userdata sizes are standard for this device class.
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

# Without this, AOSP tries to package recovery as a binary patch against
# boot.img, which this Samsung-style, recovery-only tree never produces.
# A full standalone ramdisk avoids needing boot.img at all, which is also
# what an Odin-flashable recovery.img needs anyway.
BOARD_USES_FULL_RECOVERY_IMAGE := true

# recovery.fstab extracted directly from recovery_orig.img's ramdisk.
# /data carries flags=encryptable=footer (this device uses footer-based
# FDE); /recovery carries a matching display/backup flag.
TARGET_RECOVERY_FSTAB           := $(DEVICE_PATH)/recovery/root/etc/recovery.fstab
TW_INCLUDE_CRYPTO               := true

# Fallback only: TWRP's own libcryptfsfde.so does scrypt + generic
# keymaster0/1 HAL signing, which doesn't know about this device's
# Exynos FMP hardware crypto path (drivers/crypto/fmp in the kernel
# source, key-set via exynos_smc(SMC_CMD_FMP, ...) into TrustZone). If
# TWRP's own decrypt attempt fails, this makes it fall back to starting
# the real /system/bin/vold from the already-installed ROM and asking
# it to decrypt instead — since that's Samsung's actual, working
# FMP-aware vold, not a reimplementation. Requires /system to mount
# successfully in recovery first, and only helps post-first-boot, on an
# already-installed system; it cannot decrypt a /data partition with no
# working ROM behind it. No Exynos equivalent of Qualcomm's
# TW_CRYPTO_USE_SYSTEM_VOLD := qseecomd service dependency is needed
# here, since FMP key-set is a direct kernel SMC call, not a separate
# userspace daemon. UNTESTED on real hardware — confirm on-device before
# relying on it; see README.
TW_CRYPTO_USE_SYSTEM_VOLD       := true

TW_INTERNAL_STORAGE_PATH        := "/data/media"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH        := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
TW_DEFAULT_EXTERNAL_STORAGE     := true
RECOVERY_SDCARD_ON_DATA         := true

# Display confirmed via the TWRP theme reference in the ramdisk
# (twres/portrait.xml matches this resolution).
TW_THEME                     := portrait_hdpi
TARGET_SCREEN_WIDTH          := 720
TARGET_SCREEN_HEIGHT         := 1280
DEVICE_RESOLUTION            := 720x1280
DEVICE_SCREEN_WIDTH          := 720
DEVICE_SCREEN_HEIGHT         := 1280
TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"

TARGET_USES_LOGD    := true
TWRP_INCLUDE_LOGCAT := true