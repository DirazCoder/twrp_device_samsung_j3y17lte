# AndroidProducts.mk — Samsung Galaxy J3 2017 (SM-J330F/FN/G, j3y17lte)
#
# Registers this device's product config file so it's visible to `lunch`.
# Standard TWRP/Omni-manifest shape — same pattern used across every
# device tree in this family (see joephyu's original j3y17lte tree and
# ananjaser1211's jxy17lte tree for reference, both use this exact form).

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/omni_j3y17lte.mk

COMMON_LUNCH_CHOICES := \
    omni_j3y17lte-eng \
    omni_j3y17lte-userdebug
