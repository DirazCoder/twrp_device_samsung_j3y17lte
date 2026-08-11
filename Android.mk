# Android.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# Standard TWRP device-tree module registration. This is boilerplate, not
# device-specific — same shape as any minimal TWRP device tree with no
# custom recovery C++ HAL plugins. If this device turns out to need any
# (unconfirmed either way, see README), they'd be added as additional
# LOCAL_MODULE blocks here.

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),j3y17lte)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
