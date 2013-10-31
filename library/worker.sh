#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function worker_fork [commands]
#@ - Run a command background if FORK is set, in foreground otherwise
worker_fork() {
  [ -z "$VERBOSE" ] || echo "$*"

  if [ -z "$FORK" ]; then
    eval "$*"
  else
    eval "$*" &
  fi
}


#@function worker_kill [worker]
#@ - Kill a process and all its decendants
worker_kill() {
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
