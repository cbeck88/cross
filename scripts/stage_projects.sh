#! /usr/bin/env sh

stage_projects()
(
  host="$1"
  projects="$2"
  prefix="$3"
  
  mkdir -p "$_CROSS_STAGE_DIR/$prefix" && cd "$_CROSS_STAGE_DIR/$prefix"
  for project in $projects
  do
    printf ">>> Staging $host-$project.\n"
    tar -xf "$_CROSS_PACKAGE_DIR/$host-$project$_CROSS_COMPRESS_EXT" || exit 1
  done
)