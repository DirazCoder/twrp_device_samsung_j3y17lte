# BoardConfig.mk — Samsung Galaxy J3 2017 (j3y17lte)
#
# Sourcing, plainly:
#   - Values marked CONFIRMED were read directly off recovery_orig.img —
#     either the bootimg header (via `file`) or the actual ELF binaries
#     inside the ramdisk (extracted by hand and checked with `file`, not
#     inferred from prop strings — those can be stale, see the arch note
#     below for a concrete example of that going wrong once already).
#     The image's own fingerprint identifies it as SM-J330FN, not
#     J330F — see device.mk for the model-string note.
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
#   - This repo's own README claims the ramdisk is an SVR4 cpio archive.
#     It isn't — the actual magic bytes are 070701, which is the "newc"
#     cpio format, not old ASCII/SVR4. Doesn't change anything
#     functionally, but flagging it since it's a concrete example of a
#     claim in that README that doesn't match the actual file when
#     checked, alongside the arch mistake below.

DEVICE_PATH := device/samsung/j3y17lte

USE_CAMERA_STUB := true

# Boot image geometry — CONFIRMED via `file recovery_orig.img`:
#   "Android bootimg, kernel (0x10008000), ramdisk (0x11000000), page size: 2048"
BOARD_KERNEL_BASE     := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE  := # Exynos doesn't take cmdline arguments from boot image
BOARD_MKBOOTIMG_ARGS  := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --board SRPQC17A001RU
# --board string: CONFIRMED. Sourced from Samsung's own stock recovery
# image for this exact device — recovery.img header field BOARD_NAME
# (verified with `od -c`, no truncation/hidden chars: "SRPQC17A001RU").
# That stock image's ramdisk also carries ro.product.model=SM-J330F and
# a matching fingerprint (samsung/j3y17lteser/j3y17lte:9/.../
# J330FXWS4CUD4:user/release-keys), confirming it's genuinely Samsung's
# own recovery for this device, not a repack or third-party build. This
# replaces the earlier fabricated "SRPQE04B000RU" value (unsourced, from
# prior tree lineage) and the subsequent decision to leave it blank
# (correct at the time — recovery_orig.img's own header genuinely has no
# board string — but this stock image is a better source than either).

# Architecture — CONFIRMED by extracting recovery_orig.img's ramdisk and
# checking the actual ELF binaries with `file`: sbin/recovery, sbin/twrp,
# sbin/busybox, sbin/mke2fs, sbin/sgdisk, sbin/make_ext4fs, sbin/simg2img,
# sbin/toolbox are all "ELF 64-bit ... ARM aarch64 ... interpreter
# /sbin/linker64" — i.e. genuinely 64-bit binaries, not just a 64-bit
# kernel with 32-bit userspace on top. sbin/linker (32-bit) is also
# present but that's a secondary compat linker, not evidence the primary
# recovery binary is 32-bit — the binary that actually is recovery is
# aarch64. This directly overrides an earlier version of this file that
# set TARGET_ARCH to arm/armeabi-v7a based on a stale
# ro.zygote=zygote32 line in default.prop — that prop is leftover
# branding from an older 32-bit-era source tree per this repo's own
# README, not a description of what this ramdisk's binaries actually are.
TARGET_ARCH                  := arm64
TARGET_ARCH_VARIANT          := armv8-a
TARGET_CPU_ABI                := arm64-v8a
TARGET_CPU_ABI2                :=
TARGET_CPU_VARIANT           := cortex-a53
TARGET_CPU_SMP                := true

# 2nd-ARCH block: REMOVED. Checked every file in the extracted ramdisk —
# sbin/linker (32-bit) is the *only* 32-bit ELF anywhere in the recovery
# image; no 32-bit .so libraries or executables exist that would need it,
# and every TWRP tool binary (recovery, twrp, busybox, mke2fs, sgdisk,
# make_ext4fs, simg2img, toolbox) is aarch64. Nothing in this ramdisk
# actually exercises a 32-bit code path, so the block was dead weight.
# If a real build breaks without it, that's new evidence — re-add with a
# note on what specifically needed it.

TARGET_CPU_ABI_LIST_32_BIT := armeabi-v7a,armeabi
TARGET_CPU_ABI_LIST_64_BIT := arm64-v8a
TARGET_CPU_ABI_LIST        := arm64-v8a,armeabi-v7a,armeabi

# Platform — CONFIRMED via default.prop / recovery.fstab paths
# (ro.product.board / block device paths both reference universal7570).
TARGET_BOARD_PLATFORM         := exynos5
# GPU — CONFIRMED externally, not read off this image (recovery ramdisks
# don't reference a GPU model anywhere; TWRP renders via framebuffer, not
# through the GPU driver). Cross-checked against 5 independent spec
# sources (Notebookcheck DE/EN, CPU-Monkey, PhonesSpecs, GSMArena), all
# agreeing the Exynos 7570 uses Mali-T720 MP2, and one source explicitly
# names the SM-J330/Galaxy J3 2017 family. Previous value was missing the
# MP2 core count, which some Mali kernel driver configs key off directly.
TARGET_BOARD_PLATFORM_GPU     := mali-T720-MP2
TARGET_BOOTLOADER_BOARD_NAME  := universal7570
TARGET_NO_BOOTLOADER          := true

# Kernel — using prebuilt by default since no kernel source is synced
# into this tree. If you sync Samsung's GPL kernel source for J330F,
# point TARGET_KERNEL_SOURCE/CONFIG at it and switch off the prebuilt
# path below; do not assume the defconfig name until you've confirmed
# it against the actual GPL source drop for J330F (not J330FN).
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/kernel
TARGET_PREBUILT_DTB    := $(DEVICE_PATH)/dt.img
# dt.img — CONFIRMED, extracted from recovery_orig.img at the page-aligned
# offset given by the bootimg header's own dt_size field (0x5a800 bytes,
# not zero, so this device genuinely ships a separate DTB region rather
# than a kernel with the device tree compiled in). Magic bytes are
# "DTBH" version 2, 4 entries — Samsung's own multi-DTB table format for
# Exynos boards, not raw/corrupt data. AndroidBoard.mk in this tree wires
# TARGET_PREBUILT_DTB into an actual INSTALLED_DTIMAGE_TARGET rule, since
# setting this variable alone doesn't make ninja build dt.img.

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
#   - system/cache/userdata partition sizes (lines below) — no images for
#     these partitions exist anywhere in this repo, so there's nothing to
#     check them against. Standard-for-device-class values, unverified.
#   - Whether this actually boots on a real J330F (only ever confirmed
#     against a J330FN-fingerprinted image).
#   - Kernel source / defconfig for J330F specifically.
#
# RESOLVED since the note above was written:
#   - GPU string (mali-T720-MP2) — now externally confirmed, see comment
#     at TARGET_BOARD_PLATFORM_GPU below.
#   - --board string — CONFIRMED as SRPQC17A001RU, sourced directly from
#     Samsung's own stock recovery.img for this device (SM-J330F, matching
#     fingerprint). See comment at BOARD_MKBOOTIMG_ARGS above.
#   - TARGET_2ND_ARCH block — confirmed unnecessary (only one unused
#     32-bit binary in the whole ramdisk) and removed.
#   - Architecture — independently re-confirmed against a second,
#     unrelated recovery image (different build, different source) that
#     also uses aarch64 binaries and the same core partition layout as
#     this tree. Two separate images, same answer.
