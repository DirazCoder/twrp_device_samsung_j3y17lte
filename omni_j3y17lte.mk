# omni_j3y17lte.mk — product definition for Samsung Galaxy J3 2017 (j3y17lte)
#
# Thin wrapper inheriting device.mk, per standard Omni-manifest TWRP tree
# convention (this exact filename/shape was also used in joephyu's
# original 2017 j3y17lte tree — same pattern, kept for consistency with
# what devs already familiar with this device's history will expect).

$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_NAME := omni_j3y17lte
PRODUCT_DEVICE := j3y17lte
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-J330F
PRODUCT_MANUFACTURER := samsung
