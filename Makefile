# Makefile
SDK_PATH = sdks/iPhoneOS15.6.sdk
SDK_URL = https://github.com/theos/sdks.git

OUTPUT_DIR = Blueprint/FridaCodeManager.app
SWIFT := $(wildcard ./FCM/*.swift)
VERSION = 1.4

# Check if SDK exists. If not, get.
create:
	-mkdir Product
	@if [ ! -f $(SDK_PATH) ]; then \
		echo "SDK not found. Cloning the repository..."; \
		git clone $(SDK_URL) $(dirname $(SDK_PATH)); \
	fi

all: create compile_swift package deb clean
roothide: create compile_swift package_roothide deb clean

compile_swift:
	@echo "\nIts meant to be compiled on jailbroken iOS devices in terminal, compiling it using macos can cause certain anomalies with UI, etc\n"
	swiftc -Xcc -isysroot -Xcc $(SDK_PATH) -sdk $(SDK_PATH) $(SWIFT) FCM/Libraries/libroot/libroot.a FCM/Libraries/libfcm/libfcm.a -o "$(OUTPUT_DIR)/swifty" -parse-as-library -import-objc-header FCM/Libraries/bridge.h -target arm64-apple-ios15.0
	ldid -S./FCM/ent.xml $(OUTPUT_DIR)/swifty

pre_package:
	find . -type f -name ".DS_STORE" -delete
	-rm -rf .package
	mkdir -p .package/DEBIAN
	cp control .package/DEBIAN
	@echo "Version: $(VERSION) >> .package/DEBIAN/control"
	bash getChangeLog.sh

package: compile_swift pre_package
	mkdir -p .package/var/jb/Applications/FridaCodeManager.app
	cp -r Blueprint/FridaCodeManager.app/* .package/var/jb/Applications/FridaCodeManager.app
	@echo "Architecture: iphoneos-arm64 >> .package/DEBIAN/control"
	mv .package/changelog .package/var/jb/Applications/FridaCodeManager.app/

package_roothide: compile_swift pre_package
	mkdir -p .package/Applications/FridaCodeManager.app
	cp -r Blueprint/FridaCodeManager.app/* .package/Applications/FridaCodeManager.app
	@echo "Architecture: iphoneos-arm64e >> .package/DEBIAN/control"
	mv .package/changelog .package/Applications/FridaCodeManager.app/

deb:
	-rf -f Products/*.deb
	dpkg-deb -b .package Product/FridaCodeManager.deb

clean:
	rm -rf $(OUTPUT_DIR)/swifty .package
