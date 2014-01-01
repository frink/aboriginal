#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function build_if_needed [package]
#@ - build a package if needed
build_if_needed() {
  # If we need to build cross compiler, assume root filesystem is stale.
  if [ -z "$NO_REBUILD" ]; then
    remove_built "$1"
  elif [ -f "$DIR_MAKE/$1-$TARGET" ]; then
    return 1
  fi

  # do build stuff

  return 0
}

#@function build_stage [target]
#@ - set build target to
build_stage() {
  export STAGE="$1"
  export STAGE_FILE="$DIR_STGS/$STAGE"

  [ -f "$STAGE_FILE" ] && source_limit "$STAGE_FILE" && exit

  local STAGES=($DIR_STGS/[0-9][0-9]-$STAGE)

  for STAGE_FILE in $DIR_STGS; do
    source_limit $STAGE_FILE
  done
}

#@function remove_built [package]
#@ - remove built packages
remove_built() {
  for package in "$@"; do
    PATH="$SAVEPATH" rm -f "$DIR_MAKE/$package-$TARGET.tar.bz2"
  done
}

#@function build_package [build_type]
#@ - build a given package
build_package() {
  local build_type="$1"

  [ -z "$build_type" ] && show_error "Build type is not specified for build_package"

  [ -n "$PACKAGES" ] && build_tools_path $@

  in_array $build_type ${BUILD_TYPES[@]} || return 0
  env_prefix $build_type ${BUILD_ENV[@]}

  [ -z "$FORK" ] && echo -ne "  \E[33mBuilding $build_type version of $CONFIG\E[0m\n"

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
