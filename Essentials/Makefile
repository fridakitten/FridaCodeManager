# Makefile
#
# Compile all FridaCodeManager essentials
# :3
#

SHELL := /var/jb/bin/bash

all: prepare libfcm-compile libdycall-compile #libsean-compile

prepare:
	@if [ -d lib/build ]; then \
		rm -rf lib/build; \
		mkdir lib/build; \
	else \
		mkdir lib/build; \
	fi

libfcm-compile:
	@$(MAKE) -C libfcm all
	@cp libfcm/tmp/lib/libfcm.a lib/build/libfcm.a
	@$(MAKE) -C libfcm clean

libsean-compile:
	@$(MAKE) -C libsean all
	@cp libsean/tmp/lib/libsean.a lib/build/libsean.a
	@$(MAKE) -C libsean clean

libdycall-compile:
	@$(MAKE) -C libdycall all
	@cp libdycall/tmp/lib/libdycall.a lib/build/libdycall.a
	@$(MAKE) -C libdycall clean

clean:
	@rm -rf lib/build
