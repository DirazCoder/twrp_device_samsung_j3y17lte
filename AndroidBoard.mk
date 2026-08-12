LOCAL_PATH := $(call my-dir)

# Wires TARGET_PREBUILT_DTB (declared in BoardConfig.mk) into the actual
# build graph. Setting TARGET_PREBUILT_DTB alone does NOT create a ninja
# rule for dt.img — bootimg.mk's recovery.img recipe depends on
# INSTALLED_DTIMAGE_TARGET, and nothing else in this tree ever defines
# that variable or copies the file into $(PRODUCT_OUT). Without this,
# ninja fails with "dt.img ... missing and no known rule to make it".
ifdef TARGET_PREBUILT_DTB
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img
$(INSTALLED_DTIMAGE_TARGET): $(TARGET_PREBUILT_DTB) | $(ACP)
	$(transform-prebuilt-to-target)
endif

# core/Makefile in this build generation has several recovery-ramdisk-adjacent
# targets (ramdisk-recovery.cpio among them) depend on INSTALLED_BOOTIMAGE_TARGET
# directly, with the comment "ramdisk-recovery.img is not a make target, so
# let's depend on the boot.img directly." This tree only ever builds
# recoveryimage (see bootimg.mk / BOARD_CUSTOM_BOOTIMG_MK), so nothing here
# defines INSTALLED_BOOTIMAGE_TARGET on its own, and ninja fails with
# "boot.img ... needed by ramdisk-recovery.cpio ... missing and no known
# rule to make it".
#
# This device has no separate normal-boot ramdisk (recovery/root is the only
# ramdisk this tree carries, and it's flashed to the AP slot as a standalone
# recovery image, not booted as normal Android from this same build). So this
# rule packages boot.img from the same kernel/DTB/recovery-ramdisk inputs
# bootimg.mk already uses for recovery.img, purely to satisfy the make graph.
# It is not meant to be flashed on its own.
INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img
# Ninja parallelizes any two rules that share a prerequisite (here,
# $(recovery_ramdisk)) without ordering one before the other -- it only
# guarantees the prerequisite itself is built first, not which consumer
# runs next. bootimg.mk's recovery.img rule depends on the same ramdisk,
# so both this placeholder and the real recovery.img can fire back-to-back
# the instant the ramdisk exists. Since this rule is graph-satisfying
# scaffolding, not a real artifact, just let it reuse recovery.img's
# already-built output instead of re-invoking mkbootimg at all -- that
# makes the ordering explicit and skips a redundant mkbootimg call.
$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_RECOVERYIMAGE_TARGET)
	@echo -e ${CL_GRN}"----- Making placeholder boot image (graph dependency only, not for flashing) ------"${CL_RST}
	$(hide) cp -f $(INSTALLED_RECOVERYIMAGE_TARGET) $@
