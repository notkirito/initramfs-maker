# initramfs-maker
A script that makes an initramfs, based on the files you give it

NOTE: I am working on this. It might take a while.
NOTE2: please give me a feature request im bored

## Dependencies/requirements:
WIP, but definitely bash and probably awk.
`devtmpfs` (CONFIG_DEVTMPFS) must be enabled (in the Linux kernel config) for the init to work, otherwise, kernel panic. (so is udev, so you probably have it compiled into your kernel anyways)

To enable it,
```bash
cd /usr/src/linux
make menuconfig
```

Use the arrow keys to highlight `Device drivers` and press enter.

Then, do the same for `Generic driver options` and finally `Maintain a devtmpfs filesystem to mount at /dev`

Then, save the kernel config and type:

```bash
make -j4 # the number of cores you have in your CPU
mount /boot # in case you have noauto in the /boot mount optionsn in your /etc/fstab
make install
grub-mkconfig -o /boot/grub/grub.cfg # update grub config
```

This should enable `devtmpfs`. Reboot after.

Required programs: `ldd busybox` (space-seperated)

## Usage:

(WIP)





## Installing

(WIP)

Copy `mkinitramfs.sh` somewhere writable by you.
