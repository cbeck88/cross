#! /usr/bin/env sh

stage_projects()
(
  host="$1"
  projects="$2"
  prefix="$3"
  decompress=$(package_decompress $host)
  ext=$(package_ext $host)
  
  mkdir -p "$_CROSS_STAGE_DIR/$prefix" && cd "$_CROSS_STAGE_DIR/$prefix"
  for project in $projects
  do
    printf ">>> Staging $host-$project.\n"
    $decompress "$_CROSS_PACKAGE_DIR/$host-$project$ext" > /dev/null 2>&1 || exit 1
  done
)