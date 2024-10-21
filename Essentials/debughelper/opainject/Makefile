# Makefile

all: SHELL := /var/jb/usr/bin/sh
all:
	clang -c *.m -framework Foundation -fPIC
	ar rcs libinject.a *.o
	rm *.o
