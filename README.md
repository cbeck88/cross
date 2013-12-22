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