#! /usr/bin/env sh

printf ">> Building GCC Prerequisites.\n"

mkdir -p "$_CROSS_PREREQ_DIR/$_CROSS_BUILD" && cd "$_CROSS_BUILD_DIR/prerequisites/$_CROSS_BUILD"

build_with_autotools "`pwd`" gmp $_CROSS_VERSION_GMP "$_CROSS_LOG_DIR/$_CROSS_BUILD" 