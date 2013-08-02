#! /usr/bin/env sh

# URLs
GNU_URL="ftp://ftp.nluug.nl/mirror/gnu"
PPL_URL="ftp://ftp.cs.unipr.it/pub/ppl/releases/$_CROSS_VERSION_PPL"
ISL_URL="ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl"
CLOOG_URL="http://www.bastoul.net/cloog/pages/download/count.php3?url=."
EXPAT_URL="http://sourceforge.net/projects/expat/files/expat/$_CROSS_VERSION_EXPAT"

MINGW_W64_URL="http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release"
MINGW_W64_SVN="svn://svn.code.sf.net/p/mingw-w64/code"

# patches
rm -f "$_CROSS_LOG_DIR/patches.log"
PPL_PATCHES="$_CROSS_PATCH_DIR/ppl-gmp-5.1.patch.txt"
BINUTILS_PATCHES="$_CROSS_PATCH_DIR/binutils-texinfo-5.0.patch.txt"
case "$_CROSS_VERSION_GCC" in
  "4.[5-6]*")
    GCC_PATCHES="$_CROSS_PATCH_DIR/gcc-CLOOG_INT.patch.txt" ;;
  *)
    GCC_PATCHES= ;;
esac
MAKE_PATCHES="$_CROSS_PATCH_DIR/make-win32.patch.txt"

printf ">> Downloading prerequisite libraries.\n"
fetch_source_release "$GNU_URL/gmp"  "gmp-$_CROSS_VERSION_GMP"     "bz2"
fetch_source_release "$GNU_URL/mpfr" "mpfr-$_CROSS_VERSION_MPFR"   "xz"
fetch_source_release "$GNU_URL/mpc"  "mpc-$_CROSS_VERSION_MPC"     "gz"
fetch_source_release "$PPL_URL"      "ppl-$_CROSS_VERSION_PPL"     "xz"  "$PPL_PATCHES"
fetch_source_release "$ISL_URL"      "isl-$_CROSS_VERSION_ISL"     "bz2"
fetch_source_release "$CLOOG_URL"    "cloog-$_CROSS_VERSION_CLOOG" "gz"
fetch_source_release "$EXPAT_URL"    "expat-$_CROSS_VERSION_EXPAT" "gz"

printf ">> Downloading MinGW-w64 goodies.\n"
if [ "$_CROSS_VERSION_MINGW_W64" = "trunk" ]
then
  fetch_source_svn "$MINGW_W64_SVN" "trunk" "mingw-w64-trunk"
else
  fetch_source_release "$MINGW_W64_URL" "mingw-w64-v$_CROSS_VERSION_MINGW_W64" "gz"
fi

printf ">> Downloading toolchain components.\n"
fetch_source_release "$GNU_URL/binutils" "binutils-$_CROSS_VERSION_BINUTILS"          "bz2" "$BINUTILS_PATCHES"
fetch_source_release "$GNU_URL/gcc/gcc-$_CROSS_VERSION_GCC" "gcc-$_CROSS_VERSION_GCC" "bz2" "$GCC_PATCHES"

printf ">> Downloading extra toolchain components.\n"
fetch_source_release "$GNU_URL/gdb"  "gdb-$_CROSS_VERSION_GDB"   "bz2"
fetch_source_release "$GNU_URL/make" "make-$_CROSS_VERSION_MAKE" "bz2" "$MAKE_PATCHES"
