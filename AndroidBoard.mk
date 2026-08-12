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
