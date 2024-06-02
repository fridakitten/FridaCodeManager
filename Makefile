# Makefile

SDK_PATH = sdks/iPhoneOS15.6.sdk
OUTPUT_DIR = Blueprint/FridaCodeManager.app
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
all: compile_swift package deb clean
roothide: compile_swift package_roothide deb clean

compile_swift:
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n"
	swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/Libraries/libroot/libroot.a FCM/Libraries/libfcm/libfcm.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -target arm64-apple-ios15.0
	ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

package:
	find . -type f -name ".DS_Store" -delete
	-rm -rf .package
	mkdir .package
	mkdir -p .package/var/jb/Applications/FridaCodeManager.app
	cp -r Blueprint/FridaCodeManager.app/* .package/var/jb/Applications/FridaCodeManager.app
	mkdir -p .package/var/jb/Applications/FridaCodeManager.app/sdk
	cp -r sdks/iPhoneOS15.6.sdk .package/var/jb/Applications/FridaCodeManager.app/sdk/iPhoneOS15.6.sdk
	mkdir -p .package/DEBIAN
	echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: 1.2\nArchitecture: iphoneos-arm64\nDescription: .\nDepends: swift-5.7.2, swift, zip, ldid, git, unzip, clang\nIcon: https://dekotas.org/asset/fcm/icon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FridasCoolCodingTeam\nAuthor: FridasCoolCodingTeam\nSection: Tweaks\nTag: role::hacker" > .package/DEBIAN/control

package_roothide:
	find . -type f -name ".DS_Store" -delete
	-rm -rf .package
	mkdir .package
	mkdir -p .package/Applications/FridaCodeManager.app
	cp -r Blueprint/FridaCodeManager.app/* .package/Applications/FridaCodeManager.app
	mkdir -p .package/Applications/FridaCodeManager.app/sdk
	cp -r sdks/iPhoneOS15.6.sdk .package/Applications/FridaCodeManager.app/sdk/iPhoneOS15.6.sdk
	mkdir -p .package/DEBIAN
	echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: 1.2\nArchitecture: iphoneos-arm64e\nDescription: .\nDepends: swift-5.7.2, swift, zip, ldid, git, unzip, clang\nIcon: https://dekotas.org/asset/fcm/icon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FridasCoolCodingTeam\nAuthor: FridasCoolCodingTeam\nSection: Tweaks\nTag: role::hacker" > .package/DEBIAN/control

deb:
	-rm -rf Product/FridaCodeManager.deb
	dpkg-deb -b .package Product/FridaCodeManager.deb

clean:
	rm -rf $(OUTPUT_DIR)/swifty .package
