#! /usr/bin/env sh

printf "> Preparing.\n"
. ./prepare.sh

echo $_CROSS_DIR
printf "> Fetching sources.\n"
. ./fetch_sources.sh

printf "> Building cross-compilers.\n"
build_crosscompiler "mingw32"
build_crosscompiler "mingw64"

printf "All done!\n"
