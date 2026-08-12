# Android.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# Standard TWRP device-tree module registration. Uses ifneq/filter (more
# permissive matching against TARGET_DEVICE) and all-makefiles-under
# rather than all-subdir-makefiles, matching joephyu's original tree.

ifneq ($(filter j3y17lte,$(TARGET_DEVICE)),)

LOCAL_PATH := $(call my-dir)

include $(call all-makefiles-under,$(LOCAL_PATH))

endif
