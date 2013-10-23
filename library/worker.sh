#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function fork_worker [commands]
#@ - Run a command background if FORK is set, in foreground otherwise
fork_worker() {
  [ -z "$VERBOSE" ] || echo "$*"

  if [ -z "$FORK" ]; then
    eval "$*"
  else
    eval "$*" &
  fi
}


#@function kill_worker [worker]
#@ - Kill a process and all its decendants
kill_worker() {
  local KIDS=""

  while [ $# -ne 0 ]; do
    KIDS="$KIDS $(pgrep -P$1)"

    shift
  done

  KIDS="$(echo -n $KIDS)"

  if [ ! -z "$KIDS" ]; then
    kill_worker $KIDS

    kill $KIDS 2>/dev/null
  fi
}
