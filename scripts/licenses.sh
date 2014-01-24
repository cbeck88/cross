#! /usr/bin/env sh

copy_licenses()
(
  project="$1"
  files="$2"

  licensedir="$_CROSS_STAGE_INSTALL_DIR/licenses/$project"
  mkdir -p "$licensedir"
  
  printf ">>> Copying licences for $project.\n"
  
  for file in $files
  do
    cp "$_CROSS_SOURCE_DIR/$project/$file" "$licensedir/"
  done
)
