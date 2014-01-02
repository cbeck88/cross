#! /usr/bin/env sh

# build prerequisites check
check_executables()
(
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
)

. ./functions/build_gcc_prerequisites.sh
. ./functions/build_gnu_toolchain.sh
. ./functions/build_mingw_toolchain.sh
. ./build_with_autotools.sh
. ./download_sources.sh
