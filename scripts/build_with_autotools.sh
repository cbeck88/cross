#! /usr/bin/env sh

build_with_autotools()
(
  project="$1"
  builddir="$2/$project"
  version="$3"
  logdir="$4/$project"
  configureargs="$5"
  makebuildargs="$6"
  if [ -z "$7" ]
  then
    makeinstallargs="install"
  else
    makeinstallargs="$7"
  fi
  buildstep="$8"
  
  mkdir -p "$logdir"
  mkdir -p "$builddir" && cd "$builddir"

  
  
  if [ -f "$builddir/configure$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already configured.\n"
  else
    printf ">>> Configuring $project$buildstep.\n"
    # eval for quoting magic
    eval sh "$_CROSS_SOURCE_DIR/$project-$version/configure" $configureargs > "$logdir/configure$buildstep.log" 2>&1 \
       || { printf "Failure configuring $project$buildstep. Check $logdir/configure$buildstep.log for details.\n"; exit 1; }
  fi
  touch "$builddir/configure$buildstep.marker"

  mkdir -p "$builddir" && cd "$builddir"

  if [ -f "$builddir/build$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already built.\n"
  else
    printf ">>> Building $project$buildstep.\n"
    make $makebuildargs > "$logdir/build.log" > "$logdir/build$buildstep.log" 2>&1 \
      || { printf "Failure building $project. Check $logdir/build$buildstep.log for details.\n"; exit 1; }
  fi
  touch "$builddir/build$buildstep.marker"
  
  if [ -f "$builddir/install$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already installed.\n"
  else
    printf ">>> Installing $project$buildstep.\n"
    make $makeinstallargs > "$logdir/install.log" > "$logdir/install$buildstep.log" 2>&1 \
      || { printf "Failure installing $project. Check $logdir/install$buildstep.log for details.\n"; exit 1; }
  fi
  touch "$builddir/install$buildstep.marker"
  
  cd "$_CROSS_DIR"
)
