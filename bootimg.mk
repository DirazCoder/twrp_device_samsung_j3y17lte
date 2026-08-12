LOCAL_PATH := $(call my-dir)

FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/recovery.tar

ifdef TARGET_PREBUILT_DTB
	BOARD_MKBOOTIMG_ARGS += --dt $(TARGET_PREBUILT_DTB)
endif

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) $(recovery_kernel) $(recovery_ramdisk)
	@echo -e ${CL_GRN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@ --ramdisk $(recovery_ramdisk)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
	@echo -e ${CL_GRN}"----- Lying about SEAndroid state to Samsung bootloader ------"${CL_RST}
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_RECOVERYIMAGE_TARGET)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)
	@echo -e ${CL_CYN}"Made Odin flashable recovery tar: ${FLASH_IMAGE_TARGET}"${CL_RST}

# AndroidBoard.mk defines INSTALLED_BOOTIMAGE_TARGET as a placeholder --
# some core/Makefile targets in this build generation (ramdisk-recovery.cpio
# among them) reference it directly even though BOARD_USES_FULL_RECOVERY_IMAGE
# means this tree never actually builds a delta-against-boot recovery, and
# never flashes a real boot.img either way. That rule has to live here, not
# in AndroidBoard.mk, because this file is included by core/Makefile via
# BOARD_CUSTOM_BOOTIMG_MK well after AndroidBoard.mk is parsed.
#
# This must NOT depend on $(INSTALLED_RECOVERYIMAGE_TARGET). An earlier
# version did (copying recovery.img into place as a shortcut), which closes
# a cycle: core's ramdisk-recovery.cpio rule already depends on
# INSTALLED_BOOTIMAGE_TARGET, so making that target depend back on
# recovery.img -- which itself depends on ramdisk-recovery.img and
# ramdisk-recovery.cpio -- gives ninja "recovery.img -> ramdisk-recovery.img
# -> ramdisk-recovery.cpio -> boot.img -> recovery.img" and a hard failure
# ("dependency cycle"), not a warning. The placeholder only needs to exist
# as a file; it's never flashed, so there's nothing to gain by deriving its
# content from recovery.img, and doing so is what breaks the build.
$(INSTALLED_BOOTIMAGE_TARGET):
	@echo -e ${CL_GRN}"----- Making placeholder boot image (unused stub, not for flashing) ------"${CL_RST}
	$(hide) mkdir -p $(dir $@)
	$(hide) touch $@
