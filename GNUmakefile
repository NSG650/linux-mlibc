QEMUFLAGS ?= -M q35,smm=off -m 4G -hda image.hdd -serial stdio -smp 4

.PHONY: all
all:
	rm -f image.hdd
	$(MAKE) image.hdd

image.hdd: jinx
	$(MAKE) distro-base
	./build-support/makeiso.sh

.PHONY: debug
debug:
	JINX_CONFIG_FILE=jinx-config-debug $(MAKE) all

jinx:
	curl -o jinx https://raw.githubusercontent.com/mintsuki/jinx/trunk/jinx
	chmod +x jinx

.PHONY: distro-full
distro-full: jinx
	./jinx build-all

.PHONY: distro-base
distro-base: jinx
	./jinx build base-files bash coreutils nano less

.PHONY: run-kvm
run-kvm: image.hdd
	qemu-system-x86_64 -enable-kvm -cpu host $(QEMUFLAGS)

.PHONY: run-hvf
run-hvf: image.hdd
	qemu-system-x86_64 -accel hvf -cpu host $(QEMUFLAGS)

ovmf:
	mkdir -p ovmf
	cd ovmf && curl -o OVMF-X64.zip https://efi.akeo.ie/OVMF/OVMF-X64.zip && 7z x OVMF-X64.zip

.PHONY: run-uefi
run-uefi: image.hdd ovmf
	qemu-system-x86_64 -enable-kvm -cpu host $(QEMUFLAGS) -bios ovmf/OVMF.fd

.PHONY: run
run: image.hdd
	qemu-system-x86_64 $(QEMUFLAGS)

.PHONY: base-files-clean
base-files-clean:
	rm -rf builds/base-files* pkgs/base-files*

.PHONY: clean
clean: base-files-clean
	rm -rf iso_root sysroot image.hdd

.PHONY: distclean
distclean: jinx
	./jinx clean
	rm -rf iso_root sysroot image.hdd jinx ovmf
	chmod -R 777 .jinx-cache
	rm -rf .jinx-cache
