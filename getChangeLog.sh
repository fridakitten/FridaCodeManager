#!/usr/bin/env bash

set -e

[[ -f .package/changelog ]] && rm -f .package/changelog && touch .package/changelog

while read -r line
do
	[[ $line == "" ]] && break
	echo $line
	echo $line >> .package/changelog
done < ChangeLog

echo "The latest FCM version changelog has been written to .package/changelog."
echo "If anything goes wrong please report back to us. Thanks!"

