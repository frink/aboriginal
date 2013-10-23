#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function list_list
#@ - list of aboriginal shortcuts types
list_list() {
  echo "  List Types:"
  echo
  declare -F|cut -d' ' -f3|sed -n 's/^list_/    /p'
  echo
  echo "  See Also:"
  echo
  echo "    $CALL help"
  echo
}

#@function list_help
#@ - list of aboriginal help topics
list_help() {
  echo "  Help Topics:"
  echo
  ls $DIR_HELP | xargs -I {} echo "    {}"
  echo
  echo "  See Also:"
  echo
  echo "    $CALL list"
  echo
}

#@function list_config
#@ - list of config files
list_config() {
  list_packages
  list_targets
}

#@function list_build
#@ - list build configuration
list_build() {
  list_targets
  list_stages
}

#@function list_targets
#@ - list of build targets
list_targets() {
  echo "  Build Targets:"
  find $DIR_CONF -type d|sed -e "s/^.\{${#DIR_CONF}\}/   /" -e 's/\// /g'|sort
  echo
}

#@function list_stage
#@ - list stage configuration
list_stage() {
  list_stages
  list_targets
}

#@function list_stages
#@ - list of aboriginal build stages
list_stages() {
  echo "  Build Stages:"
  echo
  ls $DIR_STGS | xargs -I {} echo "    {}"
  echo
}

#@function list_commands
#@ - list of aboriginal commands
list_commands() {
  echo "  Aboriginal Commands:"
  show_docs aboriginal $CALL "$DIR_CMDS/*"
  echo
}

#@function list_functions
#@ - list of aboriginal functions
list_functions() {
  echo "  Aboriginal Internal Functions:"
  show_docs function "" "$CALL $DIR_LIBS/*"
  echo
}

#@function list_packages
#@ - list packages
list_packages() {
  echo "  Build Packages:"
  echo
  find $DIR_CONF -type f -exec basename {} \; |sort -u|grep -v build|sed -e 's/\.conf//' -e 's/^/    /'
  echo
}

#@function only_list
#@ - show a computer readable list
only_list() {
  list_$1 | sed 's/^\s*//' | tail --lines=+3 | head --lines=-1
}
