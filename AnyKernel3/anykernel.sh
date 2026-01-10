# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Larois
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=r8q
device.name2=r8qxx
device.name3=r8qxxx
device.name4=ossi
device.name5=komodo
supported.versions=11 - 16
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/platform/soc/1d84000.ufshc/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel boot install

ui_print " "
ui_print " - Spliting boot image... "

split_boot;

# dtb install
    ui_print " "
    ui_print " - Patching dtb unconditionally... "
    mv $home/kona.dtb $home/dtb
    ;;

# begin cmdline changes
if grep -q "ro.boot.verifiedbootstate=orange" /proc/cmdline; then
   ui_print " "
   ui_print " - Spoofing verified boot state to green..."
   patch_cmdline "ro.boot.verifiedbootstate=orange" "ro.boot.verifiedbootstate=green"
fi

# vbmeta install
ui_print " "
ui_print " - Patching vbmeta unconditionally... "
dd if=$home/vbmeta.img of=/dev/block/platform/soc/1d84000.ufshc/by-name/vbmeta

# dtbo install
ui_print " "
ui_print " - Patching dtbo unconditionally... "
dd if=$home/dtbo.img of=/dev/block/platform/soc/1d84000.ufshc/by-name/dtbo

# Image install
ui_print " "
ui_print " - Flashing boot image... "

flash_boot;
## end boot install
