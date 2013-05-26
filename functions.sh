#! /usr/bin/env sh

# build prerequisites check
function check_executables
{
  for program in "$@"
  do
    command -v "$program" >/dev/null 2>&1 || { echo >&2 "Command $program not found. Aborting"; exit 1; }
    echo "--> Command $program found."
  done
}

# source release downloads
function download_source_release
{
  URL="$1"
  NAME="$2"
  EXT="tar.$3"
  FILE="$NAME.$EXT"
  
  cd "$_CROSS_SOURCE_DIR"

  if [ -f "$FILE" ]
  then 
    echo "--> $FILE already downloaded."
  else
    echo "--> Downloading $FILE from $URL/$FILE."
    curl -# -L -o "$FILE" "$URL/$FILE" || exit 1
  fi
  if [ -d "$NAME" ]
  then
    echo "--> $FILE already extracted."
  else
    echo "--> Extracting $FILE."
    tar -xf "$FILE"
  fi
  
  cd "$_CROSS_SOURCE_DIR/$NAME"
  for patchfile in "${@:4}"
  do
    echo "--> Applying patch $patchfile."
    patch --forward -p0 -i "$patchfile" > "$_CROSS_LOG_DIR/patches.log" 2>&1 # failure not checked.
  done
  
  cd "$_CROSS_DIR"
}

function download_llvm
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
