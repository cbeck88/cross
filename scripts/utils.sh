#! /usr/bin/env sh

hostfromlongname()
(
  case "$1" in
    mingw32*)
      echo "i686-w64-mingw32"
      ;;
    mingw64*)
      echo "x86_64-w64-mingw32"
      ;;
    linux32*)
      echo "i686-gnu-linux"
      ;;
    linux64*)
      echo "x86_64-gnu-linux"
      ;;
    cygwin32*)
      echo "i686-pc-cygwin"
      ;;
    cygwin64*)
      echo "x86_64-pc-cygwin"
      ;;
  esac
)

suffixfromlongname()
(
  case "$1" in
    *-dw2-win32)
      echo "-dw2-win32"
      ;;
    *-dw2-posix)
      echo "-dw2-win32"
      ;;
    *-sjlj-
  
)

convertlongname()
(
  longname="$1"
  
  # first split shortname shortname-suffix
  tail=${longname#*[0-9][a-z]}
  hostname=${longname%?$tail}
  tail=${longname#$head}
  
  # then split shortname suffix
  #suffix=${tail#*[a-z][0-9]}
  #shortname=${
  
)