#! /usr/bin/env sh

# build prerequisites check
function check_executables
{
  all_programs_found=true
  for program in "$@"
  do
    command -v "$program" > /dev/null 2>&1 || { not_found="$not_found\n$program"; all_programs_found=false; }
    printf ">>> Command $program found.\n"
  done
  if ! [ $all_programs_found ]
  then
    printf >&2 "Programs not found: $not_found.\n"
    exit 1
  fi
}

# source release downloads
function fetch_source_release
{
  URL="$1"
  NAME="$2"
  EXT="tar.$3"
  FILE="$NAME.$EXT"
  
  cd "$_CROSS_SOURCE_DIR"

  if [ -f "$FILE" ]
  then 
    printf ">>> $FILE already downloaded.\n"
  else
    printf ">>> Downloading $FILE from $URL/$FILE.\n"
    curl -# -L -o "$FILE" "$URL/$FILE" || { printf "Failure downloading from $URL/$FILE.\n"; exit 1; }
  fi
  if [ -d "$NAME" ]
  then
    printf ">>> $FILE already extracted.\n"
  else
    printf ">>> Extracting $FILE.\n"
    tar -xf "$FILE"
  fi
  
  cd "$_CROSS_SOURCE_DIR/$NAME"
  for patchfile in "${@:4}"
  do
    printf ">>> Applying patch $patchfile.\n"
    printf "\-\- Patching $NAME with $patchfile:\n" >> "$_CROSS_LOG_DIR/patches.log"
    patch --forward -p0 -i "$patchfile" >> "$_CROSS_LOG_DIR/patches.log" 2>&1 # failure not checked.
  done
  
  cd "$_CROSS_DIR"
}

function fetch_llvm
{
  VERSION="$1"
  LLVM_URL="llvm.org/releases"
}

# Version control downloads
function svn_co
{
  PROJECT="$1"
  URL="$2"
}

# build functions
function build_with_autotools
{
  builddir="$1"
  project="$2"
  logdir="$3"
  configureargs="$4"
  makebuildargs="$5"
  makeinstallargs="$6"
  
  mkdir -p "$builddir" && cd "$builddir"

  if [ -f "$builddir/configure.marker" ]
  then
    printf ">>> $project already configured.\n"
  else
    printf ">>> Configuring $project.\n"
    . "$_CROSS_SOURCE_DIR/$src/configure" "$configureargs" > "$logdir/configure.log" 2>&1 \
      || { printf "Failure configuring $project. Check $logdir/configure.log for details.\n"; exit 1; }
  fi
  touch "$builddir/configure.marker"
  
  mkdir -p "$builddir" && cd "$builddir"

  if [ -f "$builddir/build.marker" ]
  then
    printf ">>> $project already built.\n"
  else
    printf ">>> Building project.\n"
    make "$makebuildargs" > "$logdir/build.log" > "$logdir/build.log" \
      || { printf "Failure building $project. Check $logdir/build.log for details.\n"; exit 1; }
  fi
  touch "$builddir/build.marker"
  
  if [ -f "$builddir/install.marker" ]
  then
    printf ">>> $project already installed.\n"
  else
    printf ">>> Building project.\n"
    make "$makebuildargs" > "$logdir/install.log" > "$logdir/install.log" \
      || { printf "Failure installing $project. Check $logdir/install.log for details.\n"; exit 1; }
  fi
  touch "$builddir/install.marker"
}
    
  