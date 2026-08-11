# BoardConfig.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# PROVENANCE: values below were extracted directly from a working,
# real-device-flashed recovery.img (TWRP 3.3.1-1, Aug 2019 build) — NOT
# copied from an unverified device tree. See the top-level README for the
# full extraction method. Everything marked "VERIFIED" was read straight
# out of the bootimg header or ramdisk of that image. Everything marked
# "UNVERIFIED / TEMPLATE" is a best-guess default based on Exynos 7570
# common config and standard Omni/TWRP conventions — you MUST confirm these
# against a real build before trusting them; they were not extractable from
# the compiled image.

DEVICE_PATH := device/samsung/j3y17lte

# ------------------------------------------------------------------------
# Kernel boot image geometry — VERIFIED, parsed from recovery.img's own
# Android bootimg header (magic "ANDROID!", standard v0/v1 layout).
# Get these wrong and mkbootimg produces an image that will NOT boot.
# ------------------------------------------------------------------------
BOARD_KERNEL_BASE       := 0x10000000
BOARD_KERNEL_PAGESIZE   := 2048
BOARD_KERNEL_OFFSET     := 0x00008000
BOARD_RAMDISK_OFFSET    := 0x01000000
BOARD_KERNEL_TAGS_OFFSET:= 0x00000100
BOARD_FLASH_BLOCK_SIZE  := $(shell echo $$((BOARD_KERNEL_PAGESIZE * 64)))
# = 131072, standard TWRP convention (pagesize * 64), not independently
# verified against this device — sanity check before relying on it.

# Extracted kernel binary size (informational, not a build var):
#   14,748,680 bytes, confirmed "Linux kernel ARM64 boot executable Image,
#   little-endian" via `file`.

# ------------------------------------------------------------------------
# Architecture — VERIFIED from default.prop
#   ro.product.cpu.abi=arm64-v8a
#   ro.product.cpu.abilist=armeabi-v7a,armeabi   <-- 32-bit userspace list,
#     this device runs a 32-bit Android userspace on a 64-bit kernel
#     (extremely common for this SoC generation). Do not be confused by
#     the mismatch — it's expected, not a typo in the source props.
# ------------------------------------------------------------------------
TARGET_ARCH             := arm64
TARGET_ARCH_VARIANT     := armv8-a
TARGET_CPU_ABI          := arm64-v8a
TARGET_CPU_ABI2         :=
TARGET_CPU_VARIANT      := generic

TARGET_2ND_ARCH          := arm
TARGET_2ND_ARCH_VARIANT  := armv7-a-neon
TARGET_2ND_CPU_ABI       := armeabi-v7a
TARGET_2ND_CPU_ABI2      := armeabi
TARGET_2ND_CPU_VARIANT   := generic

# ------------------------------------------------------------------------
# Platform — VERIFIED from default.prop
#   ro.product.board=universal7570
#   ro.board.platform=exynos5
# ------------------------------------------------------------------------
TARGET_BOARD_PLATFORM    := exynos5
TARGET_BOOTLOADER_BOARD_NAME := universal7570
TARGET_NO_BOOTLOADER     := true

# ------------------------------------------------------------------------
# UPDATE: kernel source is now real and confirmed. Samsung's GPL release
# for this device (SM-J330F, build J330FXXU3CSK2, dated Jan 2020) contains
# an EXACT defconfig and DTS match for this board — see
# exynos7570-j3y17lte-kernel-source repo, published alongside this one.
# ------------------------------------------------------------------------
TARGET_KERNEL_ARCH       := arm64
TARGET_KERNEL_HEADER_ARCH:= arm64
TARGET_KERNEL_SOURCE     := kernel/samsung/j3y17lte     # point this at exynos7570-j3y17lte-kernel-source
TARGET_KERNEL_CONFIG     := exynos7570-j3y17lte_defconfig   # VERIFIED exact filename, confirmed present in Samsung's own GPL source drop
TARGET_KERNEL_ADDITIONAL_FLAGS := ANDROID_MAJOR_VERSION=p    # VERIFIED, per Samsung's own README_Kernel.txt build instructions
# Kernel source version: Linux 3.18.91 ("Diseased Newt") — VERIFIED from
# source Makefile. Vendor kernel version does not need to match Android
# version; this is expected and correct for this SoC generation.
#
# Toolchain per Samsung's own instructions: aarch64-linux-android-4.9
# (gcc/linux-x86/aarch64/aarch64-linux-android-4.9 from AOSP prebuilts)
#
# NOTE: if you don't want to build the kernel from source, the extracted
# prebuilt kernel binary in THIS repo (device_tree/kernel) is confirmed
# working on real hardware and can be used directly instead:
# TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/kernel

# ------------------------------------------------------------------------
# Partitions — VERIFIED from etc/recovery.fstab in the extracted ramdisk.
# No A/B slots. No dynamic/"super" partition. Legacy FDE on /data.
# Sizes below are UNVERIFIED (fstab doesn't encode partition sizes except
# where explicitly stated) — confirm against `parted`/`fdisk` output from
# a real device or the stock firmware's PIT file before trusting them.
# ------------------------------------------------------------------------
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_EMMC_WIPE   := true

BOARD_BOOTIMAGE_PARTITION_SIZE     := 20971520     # UNVERIFIED, typical for this class of device
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 20971520     # UNVERIFIED
BOARD_SYSTEMIMAGE_PARTITION_TYPE   := ext4
BOARD_USERDATAIMAGE_PARTITION_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_TYPE    := ext4
BOARD_FLASH_BLOCK_SIZE             := 131072

# Legacy TWRP fstab (v1, no header row) — VERIFIED format, matches the
# extracted etc/recovery.fstab exactly. Copy that file in as-is; do not
# regenerate/reformat it, the exact device paths are load-bearing.
TW_INCLUDE_CRYPTO         := true      # VERIFIED necessary: /data uses flags=encryptable=footer
TW_INTERNAL_STORAGE_PATH  := "/data/media"     # UNVERIFIED, standard default
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"      # UNVERIFIED, standard default
TW_EXTERNAL_STORAGE_PATH  := "/external_sdcard"      # VERIFIED, matches fstab entry
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sdcard" # VERIFIED, matches fstab entry

# ------------------------------------------------------------------------
# Display — UNVERIFIED / TEMPLATE. Not extractable from a recovery image;
# TWRP reads real framebuffer geometry from the kernel/driver at runtime,
# it isn't hardcoded in the ramdisk we tore down. Confirm against the
# device's known display specs before trusting (Galaxy J3 2017 is
# reportedly 720x1280).
# ------------------------------------------------------------------------
TW_THEME := portrait_hdpi
TARGET_SCREEN_WIDTH       := 720   # UNVERIFIED
TARGET_SCREEN_HEIGHT      := 1280  # UNVERIFIED

# ------------------------------------------------------------------------
# Misc TWRP feature flags — carried over as reasonable defaults matching
# what's present in the extracted sbin/ (busybox, standard TWRP binary
# set). Not individually verified against build flags since flags don't
# appear in a compiled binary the same way.
# ------------------------------------------------------------------------
TW_NO_REBOOT_BOOTLOADER    := true    # UNVERIFIED — confirm this device even has a distinct bootloader reboot target
TARGET_USES_LOGD           := true    # matches presence of standard logd-era init imports in init.rc
TWRP_INCLUDE_LOGCAT        := true

# ------------------------------------------------------------------------
# STILL GENUINELY OPEN — even with real kernel source in hand:
#   - Which numbered DTS variant matches YOUR exact board revision.
#     Samsung's source ships FIVE variants for this exact codename:
#       exynos7570-j3y17lte_eur_open_00.dts
#       exynos7570-j3y17lte_eur_open_01.dts
#       exynos7570-j3y17lte_eur_open_02.dts
#       exynos7570-j3y17lte_eur_open_04.dts
#       (note: 03 is absent from the source drop)
#     These appear to be PCB/hardware revision variants across production
#     runs, not SIM-config variants. Nothing in the DTS model string
#     distinguishes which one matches a given physical unit — this was
#     NOT resolvable from source inspection alone. If you know your
#     device's exact board revision, or can test-boot each variant safely,
#     that's the only way to confirm. Guessing wrong here risks GPIO/pinctrl
#     mismatches (wrong buttons, wrong sensor mappings) even if the kernel
#     still boots.
#   - Graphics/HAL driver specifics beyond what's in this GPL drop (Mali
#     T720MP2 userspace blobs are proprietary, not included here — GPL
#     release covers kernel driver only, not the closed userspace blob).
#   - Exact partition byte sizes (PIT file or live `parted` needed).
#   - Whether recovery needs any device-specific C++ HAL plugins beyond
#     what's already proven working in the extracted ramdisk.
# ------------------------------------------------------------------------
