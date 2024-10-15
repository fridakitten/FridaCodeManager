# Makefile
#
# libdycall
# Meow :3
# Created by SeanIsNotAConstant on October the 12th 2024
#

# config
SHELL := /var/jb/bin/sh
CC := clang
CF := -target arm64-apple-ios15 -arch arm64
SDKROOT := sdk

# finding all C and Objective-C files
CFILES := $(shell find . -name "*.c")
MFILES := $(shell find . -name '*.m')

# compiling them to libsean16
# fishy patch
uuid := uuid

all: compile bind

compile:
	@if [ -d tmp ]; then \
		rm -rf tmp; \
		mkdir tmp tmp/out tmp/lib; \
	else \
		mkdir tmp tmp/out tmp/lib; \
	fi
	@for file in $(CFILES); do \
		$(CC) -isysroot $(SDKROOT) $(CF) -c $$file -o "tmp/out/$$($(uuid)).o"; \
	done
	@for file in $(MFILES); do \
		$(CC) -isysroot $(SDKROOT) $(CF) -c $$file -o "tmp/out/$$($(uuid)).o"; \
	done

bind:
	@ar rcs tmp/lib/libdycall.a tmp/out/*.o

clean:
	@rm -rf tmp
