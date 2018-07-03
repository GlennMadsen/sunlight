disk:=/dev/sdb
boot:=/mnt/boot
root:=/mnt/root
grub:=/mnt/grub
cores:=3


.PHONY: disk-setup disk-unmount disk-clean kernel linux-update


install: kernel
	sudo cp -r src/linux/arch/x86_64/boot/bzImage $(boot)/$(git -C src/linux tag | tail -n 1)
	sudo grub-install --target=i386-pc /dev/sdb













src/linux/.git:
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git src/linux

src/linux/.config: src/linux/.git
	make -C src/linux mrproper
	make -C src/linux defconfig

kernel: src/linux/.config
	make -C src/linux -j$(cores)

linux-update:
	git -C src/linux pull origin master
	git -C src/linux checkout $(git -C src/linux tag | tail -n 1)
	git -C src/linux reset --hard 



disk-setup:
	sudo gdisk $(disk) < x86_64.gdisk
	sudo mkfs.ext2 $(disk)1
	sudo mkfs.ext2 $(disk)2
	sudo mkfs.ext4 $(disk)3
	sudo mkswap $(disk)4
	sudo mkdir $(boot) $(root) $(grub)
	sudo mount $(disk)1 $(grub)
	sudo mount $(disk)2 $(boot)
	sudo mount $(disk)3 $(root)

disk-unmount:
	sudo umount $(disk)1 || /bin/true
	sudo umount $(disk)2 || /bin/true
	sudo umount $(disk)3 || /bin/true
	sudo rmdir $(boot) $(root) $(grub)|| /bin/true

disk-clean: disk-unmount
	sudo gdisk $(disk) < exFAT.gdisk
	sudo mkfs.exfat $(disk)
