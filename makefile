disk=/dev/sdb

.PHONY: all chroot depgraph

all: chroot

/mnt/sunlight:
	sudo gdisk $(disk) < x86_64.gdisk
	sudo mkfs.ext4 $(disk)3
	sudo mkswap $(disk)4
	sudo mkdir /mnt/sunlight
	sudo mount $(disk)3 /mnt/sunlight

/mnt/sunlight/boot: /mnt/sunlight
	sudo mkfs.ext2 $(disk)2
	sudo mkdir /mnt/sunlight/boot
	sudo mount $(disk)2 /mnt/sunlight/boot

/mnt/sunlight/boot/grub: /mnt/sunlight/boot
	sudo mkfs.ext2 $(disk)1
	sudo mkdir /mnt/sunlight/boot/grub
	sudo mount $(disk)1 /mnt/sunlight/boot/grub

clean:
	for p in $(disk)?; \
		do sudo umount $$p || /bin/true; \
	done
	# sudo time shred -n 0 -z $(disk)
	sudo rm -r /mnt/sunlight

depgraph:
	make -Bnd | make2graph | dot -Tpng -o dependencies.png
	bash chromium-browser ./dependencies.png


/mnt/sunlight/bin: /mnt/sunlight
	sudo mkdir /mnt/sunlight/bin

/mnt/sunlight/bin/bash: /mnt/sunlight/bin
	sudo cp bin/static/bash /mnt/sunlight/bin/bash

chroot: /mnt/sunlight/bin/bash
	sudo chroot /mnt/sunlight /bin/bash