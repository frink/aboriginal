#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function build_if_needed [package]
#@ - build a package if needed
build_if_needed() {
  # If we need to build cross compiler, assume root filesystem is stale.
  if [ "$DO_REBUILD" == "$1" ]; then
    remove_built "$1"
  elif [ -f "$DIR_MAKE/$1-$DO_TARGET" ]; then
    return 1
  fi

  remove_built $1

  time $DIR_STGS/$1 || exit_build $1

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
  for $stage in "$@"; do
    rm -f "$DIR_MAKE/$stage-$DO_TARGET.tar.bz2"
  done
}

#@function exit_build [package]
#@ - exit build to alert a faliure
exit_build() {
  echo "Building $1 failed!"

  exit 500
}

#@function build_config [function] [config]
#@ - build config with stage
build_config() {
  local FUNCTION="$1"
  local CONFIG="$2"
  export PACKAGES=()
  export URL=""
  export SHA1=""

  [ -z "$CONFIG" ] && CONFIG="build"

  source_quiet "$DIR_CONF/$CONFIG.conf"
  source_quiet "$DIR_CONF/$TARGET/$CONFIG.conf"
  fork_worker $FUNCTION $CONFIG

  while read x; do
    [ -n "$x" ] && build_config $1 "$x"
  done < <(echo ${PACKAGES[@]} | sed -e 's/\s/\n/g')

  return 0
}

check_build_stage_exclusion () {
  local varname=$(basename $1)

}
