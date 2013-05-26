#! /usr/bin/env sh
set -e

# Common functionality

function check_executables
{
  for program in "$@"
  do
    command -v "$program" >/dev/null 2>&1 || { echo >&2 "Command $program not found. Aborting"; exit 1; }
    echo "--> Command $program found."
  done
}
