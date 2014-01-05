#! /usr/bin/env sh

fetch_source_release()
(
  url="$1"
  name="$2"
  ext="tar.$3"
  file="$name.$ext"
  patches="$4"
  
  cd "$_CROSS_DOWNLOAD_DIR"

  if [ -d "$_CROSS_SOURCE_DIR/$name" ]
  then
    printf ">>> Found previously extracted and patched $file.\n"
    exit 0
  fi
  
  if [ -f "$file" ]
  then 
    printf ">>> $file already downloaded.\n"
  else
    printf ">>> Downloading $file from $url/$file.\n"
    curl -# -L -o "$file" "$url/$file" || { printf "Failure downloading from $url/$file.\n"; exit 1; }
  fi
  
  printf ">>> Extracting $file.\n"
  cd "$_CROSS_SOURCE_DIR"
  tar -xf "$_CROSS_DOWNLOAD_DIR/$file"

  cd "$_CROSS_SOURCE_DIR/$name"
  for patchfile in $patches #"${@:4}"
  do
    printf ">>> Applying patch $patchfile.\n"
    printf "**** Patching $name in $_CROSS_SOURCE_DIR with $patchfile:\n" >> "$_CROSS_LOG_DIR/patches.log"
    set +e
    patch --reject-file=- --forward -p0 -i "$_CROSS_PATCH_DIR/$patchfile.patch.txt" >> "$_CROSS_LOG_DIR/patches.log" 2>&1
    set -e
  done
  
  cd "$_CROSS_DIR"
)

fetch_source_svn()
(
  url="$1"
  subdir="$2"
  checkoutdir="$_CROSS_SOURCE_DIR/$3"
  
  if [ -d "$checkoutdir" ]
  then
    cd "$checkoutdir"
    existingurl=`svn info | grep 'Repository Root' | awk '{print $NF}'`
    printf "$existingurl"
  else
    mkdir -p "$checkoutdir"
    cd "$checkoutdir"
    svn co "$url/$subdir" "$checkoutdir" >> "$_CROSS_LOG_DIR/$3-svn" 2>&1 || { printf "Failure checking out $3."; exit 1; }
  fi
)

fetch_llvm()
(
  version="$1"
  url="llvm.org/releases"
)

# Version control downloads
svn_co()
(
  project="$1"
  url="$2"
)
