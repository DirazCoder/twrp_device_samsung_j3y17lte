# omni_j3y17lte.mk — product definition for Samsung Galaxy J3 2017 (j3y17lte)
#
# Thin wrapper inheriting device.mk, standard Omni-manifest TWRP shape.

$(call inherit-product, $(LOCAL_PATH)/device.mk)

# The recovery.img this tree was reverse-engineered from (recovery_orig.img)
# reports PRODUCT_MODEL=SM-J330FN, not SM-J330F. J330F/FN/G are the same
# universal7570 board and near-identical hardware, so this should still
# build and boot on a J330F, but the model string is corrected below to
# match the target device rather than carrying over FN.
PRODUCT_NAME := omni_j3y17lte
PRODUCT_DEVICE := j3y17lte
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-J330F
PRODUCT_MANUFACTURER := samsung
