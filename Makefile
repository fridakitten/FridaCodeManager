# Makefile
SDK_PATH = SDK
OUTPUT_DIR = Blueprint/FridaCodeManager.app
VERSION := 1.5.3
BUILD_PATH := .package/
JB_PATH := /
ARCH := iphoneos-arm64

# Finding SHELL
ifeq ($(wildcard /bin/sh),)
ifeq ($(wildcard /var/jb/bin/sh),)
$(error "Neither /bin/sh nor /var/jb/bin/sh found.")
endif
SHELL := /var/jb/bin/sh
else
SHELL := /bin/sh
endif

# Targets
all: ARCH := iphoneos-arm64
all: JB_PATH := /var/jb/
all: greet compile_swift sign package_fs clean done

roothide: ARCH := iphoneos-arm64e
roothide: JB_PATH := /
roothide: greet compile_swift sign  package_fs clean done

trollstore: greet compile_ts sign makechain ipa clean done

# Functions
greet:
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n "
	@echo "\033[32mcompiling FridaCodeManager\033[0m"
	@if [ ! -d "Product" ]; then \
		mkdir Product; \
   fi

compile_ts: SWIFT := $(shell find ./FCMTS/ -name '*.swift')
compile_ts:
	@swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/Libraries/libfcm/libfcm.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -framework MobileContainerManager -target arm64-apple-ios15.0

compile_swift: SWIFT := $(shell find ./FCM/ -name '*.swift')
compile_swift:
	@output=$$(swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/Libraries/libroot/libroot.a FCM/Libraries/libfcm/libfcm.a FCM/Libraries/libfload/libfload.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -framework MobileContainerManager -target arm64-apple-ios15.0 2>&1); \
    if [ $$? -ne 0 ]; then \
        echo "$$output" | grep -v "remark:"; \
        exit 1; \
    fi

sign:
	@echo "\033[32msigning FridaCodeManager $(Version)\033[0m"
	@ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

roothide_fs:
	@JB_PATH= 
	@ARCH=iphoneos-arm64e

package_fs:
	@echo "\033[32mpackaging FridaCodeManager\033[0m"
	@find . -type f -name ".DS_Store" -delete
	@-rm -rf $(BUILD_PATH)
	@mkdir $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)$(JB_PATH)Applications/FridaCodeManager.app
	@find . -type f -name ".DS_Store" -delete
	@cp -r Blueprint/FridaCodeManager.app/* $(BUILD_PATH)$(JB_PATH)Applications/FridaCodeManager.app
	@mkdir -p $(BUILD_PATH)DEBIAN
	@echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: $(VERSION)\nArchitecture: $(ARCH)\nDescription: Full fledged Xcode-like IDE for iOS\nDepends: curl, swift, zip, ldid, unzip, clang\nIcon: https://raw.githubusercontent.com/fridakitten/FridaCodeManager/main/Blueprint/FridaCodeManager.app/AppIcon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FCCT\nAuthor: FCCT\nSection: Utilities\nTag: role::hacker" > $(BUILD_PATH)DEBIAN/control
	@-rm -rf Product/*
	@dpkg-deb -b $(BUILD_PATH) Product/FridaCodeManager.deb

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

done:
	@echo "\033[32mall done! :)\033[0m"
