# Makefile

SDK_PATH = sdks/iPhoneOS15.6.sdk
OUTPUT_DIR = Blueprint/FridaCodeManager-rootless/var/jb/Applications/FridaCodeManager.app
SWIFT := $(shell find ./ -name '*.swift')
SHELL := /var/jb/bin/sh

ifeq ($(wildcard $(SDK_PATH)),)
sdk_marker := .sdk_not_exists
.PHONY: create
create:
	@git clone https://github.com/theos/sdks.git
	@mkdir Product
	@make all
endif

# initial
all: build_ipa

build_ipa: compile_swift create_payload deb

compile_swift:
	swiftc -sdk $(SDK_PATH) $(SWIFT) -o "$(OUTPUT_DIR)/swifty" -parse-as-library
	ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

create_payload:
	mkdir -p $(OUTPUT_DIR)

deb:
	mkdir -p Blueprint/FridaCodeManager-rootless/var/jb/opt/theos/sdks/iPhoneOS15.6.sdk
	cp -r sdks/iPhoneOS15.6.sdk Blueprint/FridaCodeManager-rootless/var/jb/opt/theos/sdks/iPhoneOS15.6.sdk
	dpkg-deb -b Blueprint/FridaCodeManager-rootless Product/FridaCodeManager-rootless.deb
	rm Blueprint/FridaCodeManager-rootless/var/jb/Applications/FridaCodeManager.app/swifty

clean:
	rm -rf $(OUTPUT_DIR) $(OUTPUT_IPA)