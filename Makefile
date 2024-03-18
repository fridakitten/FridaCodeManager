# Makefile

SDK_PATH = sdks/iPhoneOS15.6.sdk
OUTPUT_DIR = Blueprint/SparkCode-rootless/var/jb/Applications/FridaCodeManager.app
SWIFT := $(shell find ./ -name '*.swift')
SHELL := /var/jb/bin/sh

ifeq ($(wildcard $(SDK_PATH)),)
.PHONY: create_sdk
endif

# initial
all: build_ipa

build_ipa: compile_swift create_payload deb

compile_swift:
	swiftc -sdk $(SDK_PATH) $(SWIFT) -o "$(OUTPUT_DIR)/swifty" -parse-as-library
	ldid -S./ent.xml $(OUTPUT_DIR)/swifty

create_payload:
	mkdir -p $(OUTPUT_DIR)

deb:
	cp -r sdks/iPhoneOS15.6.sdk Blueprint/SparkCode-rootless/var/jb/opt/theos/sdks/iPhoneOS15.6.sdk
	dpkg-deb -b Blueprint/SparkCode-rootless Product/sparkcode-rootless.deb
	rm Blueprint/SparkCode-rootless/var/jb/Applications/FridaCodeManager.app/swifty

create_sdk:
	@echo SDK cloning...
	@git clone https://github.com/theos/sdks.git

clean:
	rm -rf $(OUTPUT_DIR) $(OUTPUT_IPA)