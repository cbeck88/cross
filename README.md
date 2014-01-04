cross
=====

Scripts that build a full cross-compilation environment from only a native GCC.

Usage
=====

There's only one script you need to call yourself:

cross_build.sh
  Build the MinGW-w64 cross-compilers from the ground up.
  Checks for prerequisite programs at the start before downloading any sources.

The other scripts provide supporting functions:

cross_clean.sh
  remove all the build files.
functions.sh
  all functionality used in these build scripts. Includes downloading 
   source,patching, building, packaging, post-processing.
directories.sh
  create directories and variables containing these directories.
fetch_sources.sh
  fetch various sources needed to build. Should be split off into build 
   function calls itself.

Toolchain details
=================

To be able to create a simple local install tree, each toolchain has its own
"longname". A longname consists of two OS/bitness glued together, allowing for a
unique designation of each possible toolchain combination. The ones I currently
support are:

linux32mingw32
linux32mingw64
linux32mingw32-dw2
linux32mingw64-sjlj
linux64mingw32
linux64mingw64
linux64mingw32-dw2
linux64mingw64-sjlj
  MinGW-w64 cross-compilers from 32/64-bit Linux to 32/64-bit Windows.
mingw32mingw32
mingw32mingw64
mingw32mingw32-dw2
mingw32mingw64-sjlj
mingw64mingw32
mingw64mingw64
mingw64mingw32-dw2
mingw64mingw64-sjlj
  MinGW-w64 native (cross-)compilers. Note the mismatched bitness leads to 
   executable prefixes for the compiler binaries.

The -dw2 and -sjlj suffixes denote special ABI incompatible versions of C++ 
exception handling, which might be useful to some people. The executables of 
such a toolchain will be suffixed accordingly to prevent any confusion.

The ones I would like to support in the future are:

linux32cygwin32
linux32cygwin64
linux64cygwin32
linux64cygwin64
  Cygwin cross-compilers from 32/64-bit Linux to 32/64-bit Cygwin using the
   MinGW-w64 runtime.
cygwin32mingw32
cygwin32mingw64
cygwin64mingw32
cygwin64mingw64
  MinGW-w64 cross-compilers from 32/64-bit Cygwin to 32/64-bit Windows.
mac64mingw32
mac64mingw64
  MinGW-w64 cross-compilers from 64-bit Mac OS X to 32/64-bit Windows.
...

Versions of packages used
=========================

In order to maintain maximum compatibility, the GCC prerequisite page is used 
to determine which versions of required libraries are used in these toolchains.
This ensures maximum stability for the resulting compilers.

Future directions
=================

I would have always liked to create an ABS (Arch Build System) like environment 
where a whole set of MinGW-w64 libraries and components could be compiled by 
the simple calling of a script (and lots and lots of time and disk space), but 
this seems very out of scope and other projects are already on this.
