#! /usr/bin/env sh

printf "> Preparing.\n"
. ./prepare.sh

echo $_CROSS_DIR
printf "> Fetching sources.\n"
. ./fetch_sources.sh

printf "> Building cross-compiler.\n"
build_crosscompiler "mingw32"

printf "All done!\n"
