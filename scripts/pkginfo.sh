#! /usr/bin/env sh

_CROSS_URL_GNU="ftp://ftp.nluug.nl/mirror/gnu"
_CROSS_URL_PPL="ftp://ftp.cs.unipr.it/pub/ppl/releases/$_CROSS_VERSION_PPL"
_CROSS_URL_ISL="http://isl.gforge.inria.fr" #"http://isl.gforge.inria.fr" #"ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl"
_CROSS_URL_CLOOG="http://www.bastoul.net/cloog/pages/download"
_CROSS_URL_CLOOG_PPL="ftp://gcc.gnu.org/pub/gcc/infrastructure"
_CROSS_URL_EXPAT="http://sourceforge.net/projects/expat/files/expat/$_CROSS_VERSION_EXPAT"

export _CROSS_URL_MINGW_W64="http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release"
export _CROSS_SVN_MINGW_W64="svn://svn.code.sf.net/p/mingw-w64/code"


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
    
    
}