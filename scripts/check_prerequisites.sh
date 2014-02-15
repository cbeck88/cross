#! /usr/bin/env sh

check_executables()
(
  all_programs_found=true
  for program in "$@"
  do
    command -v "$program" > /dev/null 2>&1 && printf ">>> Command $program found.\n" || { 
not_found="$not_found\n$program"; all_programs_found=false; }
    
  done
  if ! [ $all_programs_found ]
  then
    printf >&2 "Programs not found: $not_found.\n"
    exit 1
  fi
)

check_prerequisites()
(
  printf ">> Checking for interfering cross-compilers.\n"
  check_executables "i686-w64-mingw32-ld" "i686-w64-mingw32-gcc" "x86_64-w64-mingw32-ld" "x86_64-w64-mingw32-gcc" || printf ">> None found.\n"
  
  printf ">> Checking for required executables.\n"
  check_executables "gcc" "gnat" "flex" "bison" "makeinfo" "7z" "svn" "git" "make" "python" "curl" "patch"
  check_executables "python"
  printf ">> Checking executable versions.\n"
  printf ">>> Python\n"
  case `python -c 'import platform; print(platform.python_version())'` in
    3.?.?)
      printf ">>> 'python' is version 3. We (LLVM) need(s) version 2.\n"
      check_executables "python2"
      export _CROSS_PYTHON2="python2" ;;
    2.?.?)
      printf ">>> 'python is version 2.\n"
      export _CROSS_PYTHON2="python" ;;
    *)
      printf ">>> Could not detect Python version. Exiting.\n"
      exit 1 ;;
  esac
  printf ">>> Python version 2 found with command $_CROSS_PYTHON2.\n"
)
