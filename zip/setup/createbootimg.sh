#!/sbin/sh
echo \#!/sbin/sh > /tmp/createnewboot.sh
echo /tmp/mkbootimg --kernel /tmp/zImage-dtb --ramdisk /tmp/boot.img-ramdisk.gz --cmdline \"$(cat /tmp/boot.img-cmdline)\" --base 0x$(cat /tmp/boot.img-base) --pagesize $(cat /tmp/boot.img-pagesize) --ramdisk_offset 0x$(cat /tmp/boot.img-ramdiskoff) --tags_offset 0x$(cat /tmp/boot.img-tagsoff) --dt /tmp/dt.img --output /tmp/newboot.img >> /tmp/createnewboot.sh
echo "dd if=/tmp/bump >> /tmp/newboot.img" >> /tmp/createnewboot.sh
chmod 777 /tmp/createnewboot.sh
/tmp/createnewboot.sh
return $?
