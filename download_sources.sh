#! /usr/bin/env sh
set -e

# URLs
GNU_URL="ftp://ftp.nluug.nl/mirror/gnu"
PPL_URL="ftp://ftp.cs.unipr.it/pub/ppl/releases/$_CROSS_VERSION_PPL"
ISL_URL="ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl"
EXPAT_URL="http://sourceforge.net/projects/expat/files/expat/$_CROSS_VERSION_EXPAT"

echo "-> Downloading prerequisite libraries"
download_source_release "$GNU_URL/gmp"  "gmp-$_CROSS_VERSION_GMP"     "bz2"
download_source_release "$GNU_URL/mpfr" "mpfr-$_CROSS_VERSION_MPFR"   "xz"
download_source_release "$GNU_URL/mpc"  "mpc-$_CROSS_VERSION_MPC"     "gz"
download_source_release "$PPL_URL"      "ppl-$_CROSS_VERSION_PPL"     "xz"  "$_CROSS_PATCHES/ppl-gmp-5.1.patch.txt"
download_source_release "$ISL_URL"      "isl-$_CROSS_VERSION_ISL"     "bz2"
download_source_release "$EXPAT_URL"    "expat-$_CROSS_VERSION_EXPAT" "gz"

echo "-> Downloading toolchain components"
download_source_release "$GNU_URL/binutils" "binutils-$_CROSS_VERSION_BINUTILS" "bz2"
download_source_release "$GNU_URL/gcc/gcc-$_CROSS_VERSION_GCC" "gcc-$_CROSS_VERSION_GCC" "bz2"

echo "-> Downloading system runtimes"

echo "-> Downloading extra toolchain components"
download_source_release "$GNU_URL/gdb"  "gdb-$_CROSS_VERSION_GDB"   "bz2"
download_source_release "$GNU_URL/make" "make-$_CROSS_VERSION_MAKE" "bz2"