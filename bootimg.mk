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
# among them) depend on it directly even though this tree never flashes a
# real boot.img. That rule has to live here, not in AndroidBoard.mk: this
# file (bootimg.mk) is included by core/Makefile via BOARD_CUSTOM_BOOTIMG_MK
# well after AndroidBoard.mk is parsed, so a rule in AndroidBoard.mk that
# referenced $(INSTALLED_RECOVERYIMAGE_TARGET) -- which this file defines,
# a few lines up -- would evaluate that variable as still-empty at parse
# time and drop the dependency edge entirely, letting ninja run the
# placeholder before the real recovery.img exists.
$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_RECOVERYIMAGE_TARGET)
	@echo -e ${CL_GRN}"----- Making placeholder boot image (graph dependency only, not for flashing) ------"${CL_RST}
	$(hide) cp -f $(INSTALLED_RECOVERYIMAGE_TARGET) $@
