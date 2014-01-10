#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function blank_dir [directory]
#@ - make sure dir is blank
blank_dir() {
  [ -z "$1" ] && show_error "blank_dir must blank something"
  touch -c "$1" || show_error "No permission for $1"
  [ -z "$NO_CLEANUP" ] && rm -rf "$1"
  mkdir -p "$1" || show_error "Could not create $1"
}

#@function execute_config [function] [config] [params]
#@ - execute function with specified config
execute_config() {
  local CONFIG="$1"
  local FUNCTION="${@:2}"
  export PACKAGES=()
  export BUILD_TYPES=()
  export URL=""
  export SHA1=""

  source_quiet "$DIR_CONF/$CONFIG.conf"
  source_quiet "$DIR_CONF/$TARGET/$CONFIG.conf"
  $FUNCTION
  wait 2>/dev/null

  for CONFIG in "${PACKAGES[@]}"; do
    worker_fork execute_config $CONFIG $FUNCTION
  done

  return 0
}

#@function execute_config [function] [config] [params]
#@ - execute function with specified config
execute_time() {
  time (execute_config build $@; wait)
  echo
}

#@function in_array [needle] [haystack]
#@ - check if an array contains a certain item
in_array() {
  local i

  for i in "${@:2}"; do
    [ "$i" = "$1" ] && return 0
  done

  return 1
}

#@function env_prefix [prefix] [variables]
#@ - setup environment variables from prefix
env_prefix() {
  for i in ${@:2}; do
    local _i="$i_$1"
    [ -n "${!_i}" ] && export $i=${!_i}
  done
}
