# Makefile
SDK_PATH = SDK
OUTPUT_DIR = Blueprint/FridaCodeManager.app
SWIFT := $(shell find ./FCM/ -name '*.swift')
SWIFT2 := $(shell find ./FCMTS/ -name '*.swift')
VERSION = 1.5.1

ifeq ($(wildcard /bin/sh),)
ifeq ($(wildcard /var/jb/bin/sh),)
$(error "Neither /bin/sh nor /var/jb/bin/sh found.")
endif
SHELL := /var/jb/bin/sh
else
SHELL := /bin/sh
endif

all: compile_swift sign package deb clean
roothide: compile_swift sign package_roothide deb clean
trollstore: compile_ts sign makechain ipa clean

compile_ts:
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n "
	@echo "\033[32mcompiling FridaCodeManager\033[0m"
	@swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT2) FCM/Libraries/libfcm/libfcm.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -target arm64-apple-ios15.0

compile_swift:
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n "
	@echo "\033[32mcompiling FridaCodeManager\033[0m"
	@swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/Libraries/libroot/libroot.a FCM/Libraries/libfcm/libfcm.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -target arm64-apple-ios15.0 2>&1 | grep -v "remark:"

sign:
	@echo "\033[32msigning FridaCodeManager $(Version)\033[0m"
	@ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

package:
	@echo "\033[32mpackaging FridaCodeManager (rootless)\033[0m"
	@find . -type f -name ".DS_Store" -delete
	@-rm -rf .package
	@mkdir .package
	@mkdir -p .package/var/jb/Applications/FridaCodeManager.app
	@cp -r Blueprint/FridaCodeManager.app/* .package/var/jb/Applications/FridaCodeManager.app
	@mkdir -p .package/DEBIAN
	@echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: $(VERSION)\nArchitecture: iphoneos-arm64\nDescription: .\nDepends: curl, swift, zip, ldid, unzip, clang\nIcon: https://dekotas.org/asset/fcm/icon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FridasCoolCodingTeam\nAuthor: FridasCoolCodingTeam\nSection: Tweaks\nTag: role::hacker" > .package/DEBIAN/control

package_roothide:
	@echo "\033[32mpackaging FridaCodeManager (roothide)\033[0m"
	@find . -type f -name ".DS_Store" -delete
	@-rm -rf .package
	@mkdir .package
	@mkdir -p .package/Applications/FridaCodeManager.app
	@cp -r Blueprint/FridaCodeManager.app/* .package/Applications/FridaCodeManager.app
	@mkdir -p .package/DEBIAN
	@echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: $(VERSION)\nArchitecture: iphoneos-arm64e\nDescription: .\nDepends: curl, swift, zip, ldid, unzip, clang\nIcon: https://dekotas.org/asset/fcm/icon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FridasCoolCodingTeam\nAuthor: FridasCoolCodingTeam\nSection: Tweaks\nTag: role::hacker" > .package/DEBIAN/control

deb:
	@-rm -rf Product/*
	@dpkg-deb -b .package Product/FridaCodeManager.deb

makechain:
	@echo "\033[32mRunning Chainmaker\033[0m"
	@cd Chainmaker && bash build.sh

ipa:
	@echo "\033[32mcreating .ipa\033[0m"
	@-rm -rf Product/*
	@mkdir -p Product/Payload/FridaCodeManager.app
	@cp -r ./Blueprint/FridaCodeManager.app/* ./Product/Payload/FridaCodeManager.app
	@mkdir Product/Payload/FridaCodeManager.app/toolchain
	@cp -r Chainmaker/.tmp/toolchain/* Product/Payload/FridaCodeManager.app/toolchain
	@cd Product && zip -rq FridaCodeManager.tipa ./Payload/*
	@rm -rf Product/Payload

clean:
	@rm -rf $(OUTPUT_DIR)/swifty .package
