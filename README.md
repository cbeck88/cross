cross
=====

Scripts that build a full cross-compilation environment from only a native GCC.

Usage
=====

buildall.sh is a script that will build everything from the ground up, requiring only a C compiler.

Bootstrapping a Linux compiler?
===============================
Why fully bootstrap a Linux compiler?
A distribution's GCC links to the system's glibc and other assorted libraries.
In case the build machine is running newer versions of things like that glibc,
any executables built on that system may depend on those newer versions of glibc.
To prevent any newer symbols being pulled in, two GCC's need to be built:
