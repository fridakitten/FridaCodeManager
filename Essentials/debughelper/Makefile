# Makefile

all:
	make -C opainject all
	mv opainject/libinject.a libinject.a
	make -C injectable all
	mv injectable/debug.dylib debug.dylib
	clang poc.m libinject.a -framework Foundation -o poc
	ldid -Sentitlements.plist poc
