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

# The recipe for INSTALLED_BOOTIMAGE_TARGET (declared in AndroidBoard.mk)
# has to live here rather than there, since this file is included via
# BOARD_CUSTOM_BOOTIMG_MK well after AndroidBoard.mk is parsed.
#
# This must NOT depend on $(INSTALLED_RECOVERYIMAGE_TARGET). An earlier
# version did (copying recovery.img into place as a shortcut), which closes
# a cycle: core's ramdisk-recovery.cpio rule already depends on
# INSTALLED_BOOTIMAGE_TARGET, and recovery.img depends on
# ramdisk-recovery.img/.cpio in turn, so ninja hits "recovery.img ->
# ramdisk-recovery.img -> ramdisk-recovery.cpio -> boot.img ->
# recovery.img" and fails on a dependency cycle. The placeholder just
# needs to exist as a file.
$(INSTALLED_BOOTIMAGE_TARGET):
	@echo -e ${CL_GRN}"----- Making placeholder boot image (unused stub, not for flashing) ------"${CL_RST}
	$(hide) mkdir -p $(dir $@)
	$(hide) touch $@
