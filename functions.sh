#! /usr/bin/env sh

# build prerequisites check
function check_executables
{
  all_programs_found=true
  for program in "$@"
  do
    command -v "$program" >/dev/null 2>&1 || { not_found="$not_found\n$program"; all_programs_found=false; }
    echo "--> Command $program found."
  done
  if ! [ $all_programs_found ]
  then
    echo >&2 "Programs not found: $not_found."
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
