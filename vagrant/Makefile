SHELL=/bin/bash
PROVIDER=virtualbox
TARGETS=all build clean up reload halt destroy status

all: build

build: up

clean: destroy

up:
	time vagrant up --provider $(PROVIDER)

package:
	rm -f package.box
	time vagrant package

reload:
	time vagrant reload

halt:
	time vagrant halt

destroy:
	time vagrant destroy -f

status:
	vagrant status

.PHONY: $(TARGETS)
