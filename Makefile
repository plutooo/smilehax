.PHONY: all new_jap300 old_jap300 new_usa321 old_usa321 new_usa331 old_usa331 clean

PYTHON_FILES=src/*.py
HEADER_FILES=src/*.h

HTTP_BASE?=http://smealum.github.io/3ds/s

################################################################################
all: new_jap300 old_jap300 new_usa321 old_usa321 new_usa331 old_usa331
new_jap300: build/new_jap300/installer.txt build/new_jap300/installer.bin build/new_jap300/THAX build/new_jap300/BPAYLOAD
old_jap300: build/old_jap300/installer.txt build/old_jap300/installer.bin build/old_jap300/THAX build/old_jap300/BPAYLOAD
new_usa321: build/new_usa321/installer.txt build/new_usa321/installer.bin build/new_usa321/THAX build/new_usa321/BPAYLOAD
old_usa321: build/old_usa321/installer.txt build/old_usa321/installer.bin build/old_usa321/THAX build/old_usa321/BPAYLOAD
new_usa331: build/new_usa331/installer.txt build/new_usa331/installer.bin build/new_usa331/THAX build/new_usa331/BPAYLOAD
old_usa331: build/old_usa331/installer.txt build/old_usa331/installer.bin build/old_usa331/THAX build/old_usa331/BPAYLOAD
clean:
	rm -rf build/

### INSTALLER STAGE 0 (BASIC SCRIPT + INITIAL ROP) #############################
build/new_jap300/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_jap300\"" -DJAP300 -DNEW3DS
build/old_jap300/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_jap300\"" -DJAP300
build/new_usa321/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa321\"" -DUSA321 -DNEW3DS
build/old_usa321/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa321\"" -DUSA321
build/new_usa331/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa331\"" -DUSA331 -DNEW3DS
build/old_usa331/installer.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa331\"" -DUSA331

build/%/installer.txt: $(PYTHON_FILES)
	mkdir -p $(dir $@)
	python2 src/installer_stage0.py $(DEFINES) > $@

### INSTALLER STAGE 1 (ROP + INITIAL CODE) #####################################
build/new_jap300/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_jap300\"" -DJAP300 -DNEW3DS
build/old_jap300/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_jap300\"" -DJAP300
build/new_usa321/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa321\"" -DUSA321 -DNEW3DS
build/old_usa321/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa321\"" -DUSA321
build/new_usa331/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa331\"" -DUSA331 -DNEW3DS
build/old_usa331/installer.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa331\"" -DUSA331

build/%/installer.bin: build/%/installer.elf
	arm-none-eabi-objcopy -O binary $< $@

build/%/installer.elf: src/installer_stage1.s $(HEADER_FILES)
	arm-none-eabi-gcc -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o $@ $<

### PERSISTENT STAGE 0 (BASIC SCRIPT + INITIAL ROP) ############################
build/new_jap300/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_jap300\"" -DJAP300 -DNEW3DS
build/old_jap300/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_jap300\"" -DJAP300
build/new_usa321/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa321\"" -DUSA321 -DNEW3DS
build/old_usa321/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa321\"" -DUSA321
build/new_usa331/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa331\"" -DUSA331 -DNEW3DS
build/old_usa331/persistent.txt: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa331\"" -DUSA331

build/%/persistent.txt: $(PYTHON_FILES)
	python2 src/persistent_stage0.py $(DEFINES) > $@

build/%/THAX: build/%/persistent.txt
	./scripts/make_script.py $^ $@

### PERSISTENT STAGE 1 (INITIAL CODE) ##########################################
build/new_jap300/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_jap300\"" -DJAP300 -DNEW3DS
build/old_jap300/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_jap300\"" -DJAP300
build/new_usa321/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa321\"" -DUSA321 -DNEW3DS
build/old_usa321/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa321\"" -DUSA321
build/new_usa331/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"new_usa331\"" -DUSA331 -DNEW3DS
build/old_usa331/persistent.elf: DEFINES := -DHTTP_BASE="\"$(HTTP_BASE)\"" -DHAX_COMBO="\"old_usa331\"" -DUSA331

build/%/BPAYLOAD: build/%/persistent.elf
	arm-none-eabi-objcopy -O binary $< $@

build/%/persistent.elf: src/persistent_stage1.s $(HEADER_FILES)
	arm-none-eabi-gcc -x assembler-with-cpp -nostartfiles -nostdlib $(DEFINES) -o $@ $<

