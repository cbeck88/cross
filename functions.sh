#! /usr/bin/env sh

. ./scripts/build_gnu_prerequisites.sh
. ./scripts/build_gnu_toolchain.sh
. ./scripts/build_mingw_toolchain.sh
. ./scripts/build_with_autotools.sh
. ./scripts/check_prerequisites.sh
. ./scripts/download_sources.sh
. ./scripts/versions.sh
# needs versions
. ./scripts/urls.sh
