#!/bin/bash
#
# Usage: ./write.sh
#

. "$( dirname "$0" )"/config.sh

run easypdkprog -p "$PROG" -n "$PART" write "$FIRMWARE"

