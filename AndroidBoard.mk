LOCAL_PATH := $(call my-dir)

# CORRECTION: nothing in AOSP's core kernel-build rules automatically
# packs compiled .dtb files into a Samsung DTBH-format dt.img just
# because TARGET_KERNEL_SOURCE is set — that's specific packing logic,
# not a generic kernel-build side effect. The kernel source ships its
# own prebuilt tools/dtbtool (a real DTBH-format packer — verified by
# inspecting its symbol table: write_dtbh_header, calc_dtbh_size,
# make_dt_image), but nothing in the kernel tree's own Makefile or
# scripts/ calls it automatically either. So this rule still has to
# exist here, same as the old prebuilt-copy rule did — it just now
# drives real compiled .dtb outputs through dtbtool instead of copying
# a static binary.
#
# KERNEL_OUT here matches where core/kernel.mk emits kernel build
# products when TARGET_KERNEL_SOURCE is set. Assumes `make dtbs` (the
# kernel's own dtbs target, confirmed present in arch/arm64/Makefile)
# has already run and populated KERNEL_OUT/arch/arm64/boot/dts/*.dtb
# before this rule fires — if kernel.mk's default target doesn't build
# dtbs on its own, an explicit dtbs build step needs adding above this.
ifdef TARGET_KERNEL_SOURCE
DTBTOOL := $(TARGET_KERNEL_SOURCE)/tools/dtbtool
KERNEL_DTB_DIR := $(KERNEL_OUT)/arch/arm64/boot/dts
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img
$(INSTALLED_DTIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET)
	@echo -e ${CL_GRN}"----- Packing dt.img from compiled .dtb files ------"${CL_RST}
	$(hide) $(DTBTOOL) -o $@ -s 2048 -p $(TARGET_KERNEL_SOURCE)/scripts/dtc/ $(KERNEL_DTB_DIR)/
endif

# core/Makefile has ramdisk-recovery.cpio and other targets depend on
# INSTALLED_BOOTIMAGE_TARGET directly, even though this tree only ever
# builds recoveryimage (see bootimg.mk / BOARD_CUSTOM_BOOTIMG_MK) and has
# no separate normal-boot ramdisk to package. This device flashes
# recovery.img standalone to the AP slot rather than booting a normal
# Android image from this build, so boot.img here is a placeholder that
# satisfies the make graph — it's not meant to be flashed on its own.
INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
