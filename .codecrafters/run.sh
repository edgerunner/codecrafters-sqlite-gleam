#!/bin/sh
#
# This script is used to run your program on CodeCrafters
#
# This runs after .codecrafters/compile.sh
#
# Learn more: https://codecrafters.io/program-interface

set -e # Exit on failure

# TODO: Use --no-print-progress once https://github.com/gleam-lang/gleam/issues/2299 is implemented
exec gleam run --module sqlite -- "$@" \
    | grep -vE "Compiled|Running|=ERROR REPORT=|backend port|^\$"
