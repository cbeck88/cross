#! /usr/bin/env sh

echo "-> Building bootstrap GCC using system libraries."

cd "$_CROSS_BOOTSTRAP_DIR"

if [ -f kernel_headers.marker ]; then
  echo "--> Linux kernel headers already installed."
else
  cd "$_CROSS_SOURCE_DIR/linux-$_CROSS_VERSION_LINUX"
  echo "--> Checking Linux kernel header integrity."
  make headers_check > "$_CROSS_LOG_DIR/kernel_headers.log" 2>&1 || exit 1
  echo "--> Installing Linux kernel $_CROSS_VERSION_LINUX headers."
  make INSTALL_HDR_PATH="$_CROSS_BOOTSTRAP_DIR/install" headers_install > "$_CROSS_LOG_DIR/kernel_headers.log" 2>&1 # || exit 1
  cd "$_CROSS_BOOTSTRAP_DIR"
fi
touch kernel_headers.marker

if [ -f glibc_headers.marker ]; then
  echo "--> Glibc headers already installed."
else
  echo "--> Installing Glibc headers."
  mkdir -p glibc && cd glibc
  sh $_CROSS_SOURCE_DIR/glibc-$_CROSS_VERSION_GLIBC/configure --prefix=$_CROSS_BOOTSTRAP_DIR/install \
     --build=${_CROSS_BUILD} --host=${_CROSS_BUILD} \
     --with-headers="$_CROSS_BOOTSTRAP_DIR/install/include" \
     --without-cvs --disable-profile --disable-debug --without-gd \
     --with-tls \
     --enable-kernel=2.6.32 > "$_CROSS_LOG_DIR/glibc_headers_configure.log" 2>&1 || exit 1

  make cross-compiling=yes install-headers > "$_CROSS_LOG_DIR/glibc_headers_install.log" 2>&1 || exit 1
  cd "$_CROSS_BOOTSTRAP_DIR"
fi
touch glibc_headers.marker

if [ -f binutils.marker ]; then
  echo "--> Binutils bootstrap already done."
else
  echo "--> Building bootstrap binutils."
  mkdir -p binutils && cd binutils
  sh $_CROSS_SOURCE_DIR/binutils-$_CROSS_VERSION_BINUTILS/configure --prefix=$_CROSS_BOOTSTRAP_DIR/install \
     --enable-static --disable-shared \
     --enable-multilib \
     > "$_CROSS_LOG_DIR/binutils_bootstrap.log" 2>&1 || exit 1
  
  make tooldir=$_CROSS_BOOTSTRAP_DIR/install > "$_CROSS_LOG_DIR/binutils_bootstrap.log" 2>&1 || exit 1
  make tooldir=$_CROSS_BOOTSTRAP_DIR/install install > "$_CROSS_LOG_DIR/binutils_bootstrap.log" 2>&1 || exit 1
  cd "$_CROSS_BOOTSTRAP_DIR"
fi
touch binutils.marker

if [ -f gcc.marker ]; then
  echo "--> GCC bootstrap already done."
else
  echo "--> Building bootstrap GCC."
  mkdir -p gcc && cd gcc
  
  cd "$_CROSS_BOOTSTRAP_DIR"
fi
touch gcc_bootstrap.marker

