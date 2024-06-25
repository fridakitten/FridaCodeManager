#!/usr/bin/env bash

IFS= readarray -d '' arr < <(awk -v RS= -v ORS='\0' '1' ChangeLog)

echo "The first paragraph, aka the latest version changelog of FCM, is:"
echo
echo ${arr[0]}
echo
echo "If anything goes wrong please report back to us. Thanks!"

echo ${arr[0]} > .package/changelog
