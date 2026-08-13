LOCAL_PATH := $(call my-dir)

# Wires TARGET_PREBUILT_DTB (declared in BoardConfig.mk) into the build
# graph — setting that variable alone doesn't create a ninja rule for
# dt.img. bootimg.mk's recovery.img recipe depends on
# INSTALLED_DTIMAGE_TARGET, and nothing else in this tree defines it.
ifdef TARGET_PREBUILT_DTB
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img
$(INSTALLED_DTIMAGE_TARGET): $(TARGET_PREBUILT_DTB) | $(ACP)
	$(transform-prebuilt-to-target)
endif

# core/Makefile has ramdisk-recovery.cpio and other targets depend on
# INSTALLED_BOOTIMAGE_TARGET directly, even though this tree only ever
# builds recoveryimage (see bootimg.mk / BOARD_CUSTOM_BOOTIMG_MK) and has
# no separate normal-boot ramdisk to package. This device flashes
# recovery.img standalone to the AP slot rather than booting a normal
# Android image from this build, so boot.img here is a placeholder that
# satisfies the make graph — it's not meant to be flashed on its own.
INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
