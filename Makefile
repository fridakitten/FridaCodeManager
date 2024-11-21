# Makefile
SDK_PATH = SDK
OUTPUT_DIR = Blueprint/FridaCodeManager.app
VERSION := 1.7
BUILD_PATH := .package/
SWIFT := $(shell find ./FCM/ -name '*.swift')

# Finding SHELL
ifeq ($(wildcard /bin/sh),)
ifeq ($(wildcard /var/jb/bin/sh),)
$(error "Neither /bin/sh nor /var/jb/bin/sh found.")
endif
SHELL := /var/jb/bin/sh
else
SHELL := /bin/sh
endif

PLF := -LEssentials/lib/prebuild -LEssentials/lib/build -L/var/jb/usr/lib/llvm-14/lib -lclang-14 -lcheck -lzip -lsean

# Targets
all: LF := -lroot -lfcm
all: ARCH := iphoneos-arm64
all: JB_PATH := /var/jb/
all: TARGET := jailbreak
all: greet compile_swift sign package_fs clean done

roothide: LF := -lroot -lfcm
roothide: ARCH := iphoneos-arm64e
roothide: JB_PATH := /
roothide: TARGET := jailbreak
roothide: greet compile_swift sign  package_fs clean done

trollstore: LF := -lfcm
trollstore: TARGET := trollstore
trollstore: greet compile_swift sign makechain ipa clean done

# under construction!!!
stock: LF := -lfcm -ldycall
stock: TARGET := stock
stock: greet compile_swift makechain_jailed ipa clean done

# Functions
greet:
	@if [ ! -d tmp ]; then if [ ! -d SDK ]; then mkdir tmp; wget https://polcom.de/sdk/iOS15.6.zip; mv iOS15.6.zip tmp/iOS15.6.zip; cd tmp; unzip iOS15.6.zip; mv iPhoneOS15.6.sdk ../SDK; cd ..; mv SDK/System/Library/PrivateFrameworks/MobileContainerManager.framework SDK/System/Library/Frameworks/MobileContainerManager.framework; rm -rf tmp; fi; fi; if [ ! -d Blueprint/FridaCodeManager.app/include ]; then cd Blueprint/FridaCodeManager.app; git clone https://github.com/theos/headers; mv headers include; fi
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n "
	@if [ ! -d "Product" ]; then mkdir Product; fi

compile_swift:
	@echo "\033[32mcompiling Essentials\033[0m"
	@$(MAKE) -C Essentials all
	@echo "\033[32mcompiling FridaCodeManager\033[0m"
	@output=$$(swiftc -warnings-as-errors -wmo -Xlinker -lswiftCore -Xcc -IEssentials/include -D$(TARGET) -sdk $(SDK_PATH) $(SWIFT) $(PLF) $(LF) -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/bridge.h -framework MobileContainerManager -target arm64-apple-ios15.0 2>&1); \
	if [ $$? -ne 0 ]; then \
		echo "$$output" | grep -v "remark:"; \
		exit 1; \
	fi
	@$(MAKE) -C Essentials clean

sign: linkfix
sign:
	@echo "\033[32msigning FridaCodeManager $(Version)\033[0m"
	@ldid -S./FCM/debug.xml $(OUTPUT_DIR)/swifty

package_fs:
	@echo "\033[32mpackaging FridaCodeManager\033[0m"
	@find . -type f -name ".DS_Store" -delete
	@-rm -rf $(BUILD_PATH)
	@mkdir $(BUILD_PATH)
	@mkdir -p $(BUILD_PATH)$(JB_PATH)Applications/FridaCodeManager.app
	@find . -type f -name ".DS_Store" -delete
	@cp -r Blueprint/FridaCodeManager.app/* $(BUILD_PATH)$(JB_PATH)Applications/FridaCodeManager.app
	@mkdir -p $(BUILD_PATH)DEBIAN
	@echo "Package: com.sparklechan.swifty\nName: FridaCodeManager\nVersion: $(VERSION)\nArchitecture: $(ARCH)\nDescription: Full fledged Xcode-like IDE for iOS\nDepends: swift, clang-14, ldid, git, libclang1-16\nIcon: https://raw.githubusercontent.com/fridakitten/FridaCodeManager/main/Blueprint/FridaCodeManager.app/AppIcon.png\nConflicts: com.sparklechan.sparkkit\nMaintainer: FCCT\nAuthor: FCCT\nSection: Utilities\nTag: role::hacker" > $(BUILD_PATH)DEBIAN/control
	@-rm -rf Product/*
	@dpkg-deb -b $(BUILD_PATH) Product/FridaCodeManager.deb

makechain:
	@echo "\033[32mbuilding trollstore toolchain\033[0m"
	@cd Chainmaker && bash build.sh

makechain_jailed:
	@echo "\033[32mbuilding trollstore toolchain\033[0m"
	@cd Chainmaker && bash jailed.sh

ipa:
	@echo "\033[32mcreating .ipa\033[0m"
	@-rm -rf Product/*
	@mkdir -p Product/Payload/FridaCodeManager.app
	@cp -r ./Blueprint/FridaCodeManager.app/* ./Product/Payload/FridaCodeManager.app
	@mkdir Product/Payload/FridaCodeManager.app/toolchain
	@cp -r Chainmaker/.tmp/toolchain/* Product/Payload/FridaCodeManager.app/toolchain
	@cd Product && zip -rq FridaCodeManager.tipa ./Payload/*
	@rm -rf Product/Payload

linkfix:
	@install_name_tool -add_rpath /var/jb/usr/lib/llvm-16/lib $(OUTPUT_DIR)/swifty
	@install_name_tool -add_rpath @loader_path $(OUTPUT_DIR)/swifty
	@install_name_tool -add_rpath @loader_path/toolchain/lib $(OUTPUT_DIR)/swifty

clean:
	@rm -rf $(OUTPUT_DIR)/swifty $(OUTPUT_DIR)/*.dylib .package

done:
	@echo "\033[32mall done! :)\033[0m"

