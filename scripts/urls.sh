#! /bin/env sh

printf ">> Defining download URLs.\n"
export _CROSS_URL_GNU="ftp://ftp.nluug.nl/mirror/gnu"
export _CROSS_URL_PPL="ftp://ftp.cs.unipr.it/pub/ppl/releases/$_CROSS_VERSION_PPL"
export _CROSS_URL_ISL="http://isl.gforge.inria.fr" #"http://isl.gforge.inria.fr" #"ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl"
export _CROSS_URL_CLOOG="http://www.bastoul.net/cloog/pages/download/count.php3?url=."
export _CROSS_URL_CLOOG_PPL="ftp://gcc.gnu.org/pub/gcc/infrastructure"
export _CROSS_URL_EXPAT="http://sourceforge.net/projects/expat/files/expat/$_CROSS_VERSION_EXPAT"

export _CROSS_URL_MINGW_W64="http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release"
export _CROSS_SVN_MINGW_W64="svn://svn.code.sf.net/p/mingw-w64/code"
