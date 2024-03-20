# Makefile

SDK_PATH = sdks/iPhoneOS15.6.sdk
OUTPUT_DIR = Blueprint/FridaCodeManager-rootless/var/jb/Applications/FridaCodeManager.app
SWIFT := $(shell find ./FCM/ -name '*.swift')

ifeq ($(wildcard /bin/sh),)
ifeq ($(wildcard /var/jb/bin/sh),)
$(error "Neither /bin/sh nor /var/jb/bin/sh found.")
endif
SHELL := /var/jb/bin/sh
else
SHELL := /bin/sh
endif

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
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n"
	swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/libroot/libroot.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/libroot/libroot.h -target arm64-apple-ios15.0
	ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

create_payload:
	mkdir -p $(OUTPUT_DIR)

deb:
	find . -type f -name ".DS_Store" -delete
	mkdir -p Blueprint/FridaCodeManager-rootless/var/jb/opt/theos/sdks
	cp -r sdks/iPhoneOS15.6.sdk Blueprint/FridaCodeManager-rootless/var/jb/opt/theos/sdks/iPhoneOS15.6.sdk
	dpkg-deb -b Blueprint/FridaCodeManager-rootless Product/FridaCodeManager-rootless.deb
	rm Blueprint/FridaCodeManager-rootless/var/jb/Applications/FridaCodeManager.app/swifty
	rm -rf Blueprint/FridaCodeManager-rootless/var/jb/opt

clean:
	rm -rf $(OUTPUT_DIR) $(OUTPUT_IPA)