#! /usr/bin/env sh

pkginfo()
{
  pkgname="$1"
  pkgurl=$CROSS_URL_GNU/gmp/$pkgname-$pkgver.tar.bz2
  pkgpatch=

  pkgtype=autotools
  pkgconfig="--host=$pkghost
             --build=$pkgbuild \
             --prefix=$pkgprefix \
             --disable-shared \
             --enable-static \
             --enable-cxx"

seturl()
{
  case $pkgname in
    gmp|mpfr|mpc|libiconv|gdb|binutils|gcc)
      eval '$1=$_CROSS_URL_GNU' ;;
    ppl)
      eval '$1=$_CROSS_URL_PPL' ;;
    cloog)
      eval '$1=$_CROSS_URL_CLOOG' ;;
    expat)
      eval '$1=$_CROSS_URL_EXPAT' ;;
    mingw-w64)
      eval
    
}