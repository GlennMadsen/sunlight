codename=starlight
disk=/dev/sdb

.PHONY: all clean graph

all: | create-disk 

clean:
	rm -r src
	rm -r bin

graph:
	make -Bnd | ./make2graph | dot -Tpng -o graph.png
	bash if [ command -v chromium-browser ]; \
		then chromium-browser graph.png; \
	fi




.PHONY: create-disk unmount-disk clean-disk

create-disk:
	sudo gdisk $(disk) < x86_64.gdisk
	sudo mkfs.ext2 $(disk)1
	sudo mkfs.ext2 $(disk)2
	sudo mkfs.ext4 $(disk)3
	sudo mkfs.ext4 $(disk)4
	sudo mkswap $(disk)5
	make mount-disk

mount-disk:
	sudo mkdir -p /mnt/$(codename)/boot/grub
	sudo mkdir -p /mnt/$(codename)/recovery
	sudo mount $(disk)1 /mnt/$(codename)/boot/grub
	sudo mount $(disk)2 /mnt/$(codename)/boot
	sudo mount $(disk)3 /mnt/$(codename)
	sudo mount $(disk)4 /mnt/$(codename)/recovery

unmount-disk:
	for p in $(disk)?; \
		do sudo umount $$p || /bin/true; \
	done
	sudo rm -r /mnt/$(codename) || /bin/true

clean-disk:
	make unmount-disk
	sudo time shred -v -n 0 -z $(disk)


.PHONY: install-grub


install-grub:
	grub-mkimage --config=grub.conf --prefix=/boot/grub --output=/bin/grub
	install-grub --boot-directory=/mnt/boot/grub /dev/sdb