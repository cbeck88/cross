#! /usr/bin/env sh

stage_project()
(
  host="$1"
  projects="$2"
  
  cd "$_CROSS_STAGE_DIR"
  for project in $projects
  do
    printf ">>> Staging $project.\n"
    tar -xf "$_CROSS_PACKAGE_DIR/$host-$project$_CROSS_COMPRESS_EXT"
  done
)