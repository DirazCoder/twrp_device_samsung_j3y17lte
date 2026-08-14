#!/sbin/sh
# Re-toggles the USB gadget's enable node after VBUS should be up.
# See init.recovery.usb.rc for the trigger and sepolicy/usb_reenable.te
# for the domain this runs under — kept as its own file (rather than an
# inline /sbin/sh -c string in the service definition) purely for
# readability; the domain comes from "seclabel" on the service, not
# from this file's own label.
sleep 14
usb_config=$(getprop sys.usb.config)
echo 0 > /sys/class/android_usb/android0/enable
echo "$usb_config" > /sys/class/android_usb/android0/functions
echo 1 > /sys/class/android_usb/android0/enable
