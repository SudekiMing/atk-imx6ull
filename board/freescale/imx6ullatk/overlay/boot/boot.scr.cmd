# ./tools/mkimage -C none -A arm -T script -d boot.scr.cmd boot.scr.uimg
#

# Update DISTRO command= search in sub-directory
env set boot_prefixes "/${boot_device}${boot_instance}_${board_name}_"

if test ${boot_device} = mmc; then
    #start the correct exlinux.conf
    run scan_dev_for_boot_part
fi

echo SCRIPT FAILED... ${boot_prefixes}extlinux/extlinux.conf not found !