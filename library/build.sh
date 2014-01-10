#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function build_if_needed [package]
#@ - build a package if needed
build_if_needed() {
  # If we need to build cross compiler, assume root filesystem is stale.
  if [ -z "$NO_REBUILD" ]; then
    build_clean "$1" "$2"
  elif [ -f "$DIR_TEMP/$2-$1" ]; then
    return 1
  fi

  build_setup "$1" "$2"

  return 0
}

#@function build_test_static
#@ - test compiler sanity
build_test_static() {
  $CC "$DIR_TEST/check-compiler.c" --static -o "$DIR_TEMP/compiled-static" && local COMPILES=$("$DIR_TEMP/compiled-static") && rm "$DIR_TEMP/compiled-static"


  if [ "$COMPILES$?" != "Compiles0" ]; then
    show_error "Your host toolchain does not allow static linking. Install support or add BUILD_STATIC=false to your config files."
  fi
}

#@function build_setup [package]
#@ - setup a build for the specified package
build_setup() {
  TARGET=$1
  CONFIG=$2
  BUILD_DIR="$DIR_TEMP/$CONFIG-$TARGET"

  # make directory
  [ ! -d "$BUILD_DIR" ] && mkdir "$BUILD_DIR"

  if [ "$BUILD_STATIC" = "false" ] || in_array "$BUILD_TYPE" "hosttools" "essentials"; then
    export BUILD_STATIC=""
  else
    export BUILD_STATIC="--static"
  fi

  OLD_CPUS=$CPUS
  OLD_NO_CLEAN=$NO_CLEANUP
  in_array $CONFIG $DEBUG_PACKAGES && CPUS=1 && NO_CLEANUP=1

  echo  "  "$CC $BUILD_STATIC $CONFIG $TARGET $BUILD_TYPE $CPUS $NO_CLEANUP

  CPUS=$OLD_CPUS
  NO_CLEANUP=$OLD_NO_CLEANUP
}

#@function build_clean [packages]
#@ - remove built packages
build_clean() {
  for package in ${@:2}; do
    rm -f "$DIR_TEMP/$package-$1*"
  done
}

#@function build_package [build_type]
#@ - build a given package
build_package() {
  export BUILD_TYPE="$1"

  [ -z "$BUILD_TYPE" ] && show_error "Build type is not specified for build_package"
  [ -n "$PACKAGES" ] && build_tools_path $@
  [ "$BUILD_STATIC" != "false" ]
  build_test_static

  in_array $BUILD_TYPE ${BUILD_TYPES[@]} || return 0
  env_prefix $BUILD_TYPE ${BUILD_ENV[@]}

  [ -z "$FORK" ] && echo -ne "  \E[33mBuilding $BUILD_TYPE version of $CONFIG\E[0m\n"

  build_if_needed $TARGET $CONFIG
}

#@function build_tools_path
#@ - create path for host tools
build_tools_path() {
  build_tools_links $@

  export PATH="$DIR_HOST"
  local i=1

  while [ -e "$DIR_HOST/$i" ]; do
    PATH="$PATH:$DIR_HOST/$i"
    i=$[$i+1]
  done

  PATH="$PATH:$SAVEPATH"
}

#@function build_tools_path
#@ - create symlinks for all versions of build tools
build_tools_links() {
  (PATH="$SAVEPATH"
    rm -rf "$DIR_HOST"

    local i=0
    local x=0
    local dir=""

    # Create symlinks to the host toolchain.  We need a usable existing host
    # toolchain in order to build anything else (even a new host toolchain),
    # and we don't really want to have to care what the host type is, so
    # just use the toolchain that's already there.

    # This is a little more complicated than it needs to be, because the host
    # toolchain may be using ccache and/or distcc, which means we need every
    # instance of these tools that occurs in the $PATH, in order, each in its
    # own fallback directory.

    for x in ar as nm cc make ld gcc $HOSTTOOL_EXTRAS; do
      i=0
      dir="$DIR_HOST"

      # Loop through each instance, populating fallback directories.
      which -a "$x" | while read xx; do
        if [ ! -e "$dir/$x" ]; then
          mkdir -p "$dir"
          ln -sfn "$xx" "$dir/$x" || oops
        fi

        i=$[$i+1]
        dir="$DIR_HOST/$i"
      done

      if [ ! -f "$DIR_HOST/$x" ]; then
        echo -e "  \e[31mToolchain component missing: $x\e[0m\n"
      fi
    done

    # Workaround for systems that make gcc a perl script that calls
    # gcc.real. Do outside of above loop to avoid thowing error

    local gcc_real="$(PATH="$SAVEPATH" "which" gcc.real)"
    [ ! -z "$gcc_real" ] && ln -s "$gcc_real" "$DIR_HOST/gcc.real" 2>/dev/null
  )
}
