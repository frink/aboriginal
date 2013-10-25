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
