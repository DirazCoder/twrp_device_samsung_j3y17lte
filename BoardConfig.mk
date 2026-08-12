# BoardConfig.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# PROVENANCE (three sources, each labeled per line):
#   [DEVICE]  = extracted directly from a working, real-device-flashed
#               recovery.img (TWRP 3.3.1-1, Aug 2019 build), or read live
#               off real hardware via `adb shell` while booted into it.
#   [REFTREE] = adopted from joephyu/android_device_samsung_j3y17lte, a
#               published, community TWRP device tree for this exact
#               codename. Used where our own extraction couldn't determine
#               a build-system-level value (build-target arch is a build
#               choice, not something recoverable from a compiled binary).
#   [TEMPLATE]= still an unverified default, flagged as such.
#
# CORRECTION LOG: an earlier version of this file set TARGET_ARCH/ABI to
# arm64, reasoning from the kernel's real 64-bit architecture. That was
# wrong — TARGET_ARCH describes the userspace build target, not kernel
# capability, and this device's proven-working tree builds a 32-bit-only
# userspace (arm/armeabi-v7a) on top of the 64-bit kernel, a common split
# for this SoC generation. Fixed below, see [REFTREE] tags in that section.

DEVICE_PATH := device/samsung/j3y17lte

USE_CAMERA_STUB := true

# ------------------------------------------------------------------------
# Kernel boot image geometry — [DEVICE] parsed from recovery.img's own
# Android bootimg header (magic "ANDROID!", standard v0/v1 layout).
# Cross-checked against [REFTREE]: BOARD_KERNEL_BASE and the mkbootimg
# offsets match exactly, independent confirmation these are correct.
# Get these wrong and mkbootimg produces an image that will NOT boot.
# ------------------------------------------------------------------------
BOARD_KERNEL_BASE        := 0x10000000
BOARD_KERNEL_PAGESIZE    := 2048
BOARD_KERNEL_CMDLINE     := # Exynos doesn't take cmdline arguments from boot image  [REFTREE]
BOARD_MKBOOTIMG_ARGS     := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --board SRPQE04B000RU
# --board string above is [REFTREE] — not independently verified by us,
# but load-bearing for Samsung's bootloader to accept the image, keep it.

# Extracted kernel binary size (informational, not a build var):
#   14,748,680 bytes, confirmed "Linux kernel ARM64 boot executable Image,
#   little-endian" via `file`. [DEVICE] — this confirms the KERNEL itself
# is arm64, which is correct and does not conflict with the arm userspace
# build target below; see CORRECTION LOG.

# ------------------------------------------------------------------------
# Architecture — [REFTREE], corrected. This device builds a 32-bit-only
# Android userspace on top of the 64-bit kernel. Our earlier arm64/arm
# primary+secondary setup was wrong for this device; joephyu's tree
# (confirmed booting on real j3y17lte hardware) uses arm as the sole
# TARGET_ARCH, no TARGET_2ND_ARCH at all.
# ------------------------------------------------------------------------
TARGET_ARCH              := arm
TARGET_ARCH_VARIANT      := armv7-a-neon
TARGET_CPU_ABI           := armeabi-v7a
TARGET_CPU_ABI2          := armeabi
TARGET_CPU_ABI_LIST_32_BIT := armeabi-v7a,armeabi
TARGET_CPU_VARIANT       := cortex-a15
TARGET_CPU_SMP           := true

# ------------------------------------------------------------------------
# Platform — [DEVICE] VERIFIED from default.prop / live device-tree query
#   ro.product.board=universal7570
#   ro.board.platform=exynos5
#   model_info-chip = 7570  (read live via /proc/device-tree)
# ------------------------------------------------------------------------
TARGET_BOARD_PLATFORM      := exynos5
TARGET_BOARD_PLATFORM_GPU  := mali-T720   # [REFTREE]
TARGET_BOOTLOADER_BOARD_NAME := universal7570
TARGET_NO_BOOTLOADER       := true

# ------------------------------------------------------------------------
# Kernel source — [DEVICE] Samsung's GPL release for this device
# (SM-J330F, build J330FXXU3CSK2, Jan 2020) contains an exact defconfig
# and DTS match for this board.
# ------------------------------------------------------------------------
# Using the prebuilt kernel by default — [DEVICE] confirmed working on
# real hardware, and no kernel source repo is currently synced into this
# tree at the path below. Uncomment TARGET_KERNEL_SOURCE/CONFIG/FLAGS
# below (and sync exynos7570-j3y17lte-kernel-source to that path) only if
# you actually want to build the kernel from source instead of reusing
# the known-good prebuilt.
TARGET_PREBUILT_KERNEL    := $(DEVICE_PATH)/kernel

# TARGET_KERNEL_ARCH        := arm64
# TARGET_KERNEL_HEADER_ARCH := arm64
# TARGET_KERNEL_SOURCE      := kernel/samsung/j3y17lte     # point this at exynos7570-j3y17lte-kernel-source
# TARGET_KERNEL_CONFIG      := exynos7570-j3y17lte_defconfig   # [DEVICE] confirmed present in Samsung's own GPL source drop
# TARGET_KERNEL_ADDITIONAL_FLAGS := ANDROID_MAJOR_VERSION=p    # [DEVICE] per Samsung's own README_Kernel.txt

# Board revision / DTS variant — [DEVICE] confirmed directly from real
# hardware. Read on-device via `adb shell` while booted into the working
# recovery:
#   /proc/device-tree/model_info-hw_rev     = <4>   (decimal)
#   /proc/device-tree/model_info-hw_rev_end = <255> (decimal)
# Cross-checked against Samsung's GPL kernel source, where each DTS
# variant declares its own hw_rev/hw_rev_end range:
#   _00: hw_rev 0,   hw_rev_end 0
#   _01: hw_rev 1,   hw_rev_end 1
#   _02: hw_rev 2,   hw_rev_end 3
#   _04: hw_rev 4,   hw_rev_end 255   <-- exact match to this device
TARGET_KERNEL_DTB_PATH    := arch/arm64/boot/dts/exynos7570-j3y17lte_eur_open_04.dtb
TARGET_KERNEL_DTB_NAME    := exynos7570-j3y17lte_eur_open_04
TARGET_PREBUILT_DTB       := $(DEVICE_PATH)/dt.img   # [REFTREE] — build system expects a compiled dt.img alongside the kernel
# Kernel source version: Linux 3.18.91 ("Diseased Newt") — [DEVICE]
# Toolchain per Samsung's own instructions: aarch64-linux-android-4.9
#
# TARGET_PREBUILT_KERNEL is set above as the default build path.

# ------------------------------------------------------------------------
# Partitions — [DEVICE] fstab layout confirmed from etc/recovery.fstab in
# the extracted ramdisk. Sizes below confirmed via `cat /proc/partitions`
# on real hardware (converted from 1024-byte blocks):
#   BOOT (mmcblk0p9)      = 32,768 KB  = 33,554,432 bytes
#   RECOVERY (mmcblk0p10) = 38,912 KB  = 39,845,888 bytes
# [REFTREE] uses hex 0x2000000 (33,554,432) / 0x2600000 (39,845,888) —
# these match our device-measured values exactly, independent confirmation.
# No A/B slots. No dynamic/"super" partition. Legacy FDE on /data.
# ------------------------------------------------------------------------
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_SUPPRESS_EMMC_WIPE   := true
BOARD_HAS_NO_MISC_PARTITION := true   # [REFTREE]
BOARD_USES_MMCUTILS        := true    # [REFTREE]
BOARD_HAS_SDCARD_INTERNAL  := true    # [REFTREE]
BOARD_SUPPRESS_SECURE_ERASE := true   # [REFTREE]

BOARD_BOOTIMAGE_PARTITION_SIZE     := 0x2000000   # 33,554,432 bytes — [DEVICE]+[REFTREE] agree
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x2600000   # 39,845,888 bytes — [DEVICE]+[REFTREE] agree
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 0xAC000000  # [REFTREE], not independently measured
BOARD_CACHEIMAGE_PARTITION_SIZE    := 0xC800000   # [REFTREE], not independently measured
BOARD_USERDATAIMAGE_PARTITION_SIZE := 0x2DE000000 # [REFTREE], not independently measured
BOARD_SYSTEMIMAGE_PARTITION_TYPE   := ext4
BOARD_USERDATAIMAGE_PARTITION_TYPE := ext4
BOARD_CACHEIMAGE_PARTITION_TYPE    := ext4
BOARD_FLASH_BLOCK_SIZE             := 131072
BOARD_HAS_LARGE_FILESYSTEM         := true
TARGET_USERIMAGES_USE_EXT4         := true
TARGET_USERIMAGES_USE_F2FS         := true   # [REFTREE]

BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/bootimg.mk   # [REFTREE] — required file, see below

# Legacy TWRP fstab (v1, no header row) — [DEVICE] matches the extracted
# etc/recovery.fstab exactly. Copy that file in as-is.
TARGET_RECOVERY_FSTAB     := $(DEVICE_PATH)/recovery/root/etc/recovery.fstab
TW_INCLUDE_CRYPTO         := true      # [DEVICE] necessary: /data uses flags=encryptable=footer
TW_INTERNAL_STORAGE_PATH  := "/data/media"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH  := "/external_sd"        # corrected to match [REFTREE]'s fstab mount name
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"   # corrected to match [REFTREE]'s fstab mount name
TW_DEFAULT_EXTERNAL_STORAGE := true   # [REFTREE]
RECOVERY_SDCARD_ON_DATA   := true     # [REFTREE]

# ------------------------------------------------------------------------
# Display — [DEVICE] empirically confirmed: TWRP UI observed rendering
# full-screen, correctly proportioned, on real hardware. Also matches
# [REFTREE]'s value exactly (720x1280), independent confirmation.
# ------------------------------------------------------------------------
TW_THEME              := portrait_hdpi
TARGET_SCREEN_WIDTH   := 720
TARGET_SCREEN_HEIGHT  := 1280
DEVICE_RESOLUTION      := 720x1280   # [REFTREE]
DEVICE_SCREEN_WIDTH    := 720        # [REFTREE]
DEVICE_SCREEN_HEIGHT   := 1280       # [REFTREE]
TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"   # [REFTREE]

# ------------------------------------------------------------------------
# Misc TWRP feature flags
# ------------------------------------------------------------------------
TW_NO_REBOOT_BOOTLOADER := true    # [TEMPLATE] — unverified whether this device has a distinct bootloader reboot target
TARGET_USES_LOGD        := true
TWRP_INCLUDE_LOGCAT     := true

# ------------------------------------------------------------------------
# STILL GENUINELY OPEN:
#   - Graphics/HAL driver specifics beyond this GPL drop (Mali T720MP2
#     userspace blobs are proprietary — GPL release covers kernel driver
#     only, not the closed userspace blob; not needed for recovery's
#     framebuffer-only UI, but flagged since it can't be verified absent).
#   - System/cache/userdata partition sizes are [REFTREE]-sourced only,
#     not independently measured on our own device — boot/recovery sizes
#     (the ones that actually matter for building recovery itself) ARE
#     independently measured and agree with [REFTREE].
#   - `lunch omni_j3y17lte-eng` — pending confirmation from current build
#     attempt.
#
# RESOLVED:
#   - DTS board-revision variant: confirmed exynos7570-j3y17lte_eur_open_04
#     via /proc/device-tree/model_info-hw_rev on real hardware.
#   - Boot/recovery partition sizes: confirmed via /proc/partitions,
#     independently matches [REFTREE]'s values.
#   - Display geometry: confirmed via visual check on real hardware,
#     independently matches [REFTREE]'s values.
#   - TARGET_ARCH/ABI: corrected from an unverified arm64 guess to the
#     proven-working arm/armeabi-v7a build target, per [REFTREE].
# ------------------------------------------------------------------------
