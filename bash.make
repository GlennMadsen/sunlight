arc/bash.tar.gz: arc
	curl http://ftp.gnu.org/gnu/bash/bash-4.4.tar.gz > arc/bash.tar.gz

src/bash: src arc/bash.tar.gz
	tar -C src -xzf arc/bash.tar.gz bash-4.4
	mv src/bash-4.4 src/bash

bin/bash: bin src/bash
	(cd src/bash && CC=clang ./configure --enable-static-link)
	make -C src/bash
	cp src/bash/bash bin/bash

/mnt/$(codename)/recovery/bin: /mnt/$(codename)/recovery
	mkdir /mnt/$(codename)/recovery/bin

/mnt/$(codename)/recovery/bin/bash: /mnt/$(codename)/recovery/bin
	cp bin/bash /mnt/$(codename)/recovery/bin/bash