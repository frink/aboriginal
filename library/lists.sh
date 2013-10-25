#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

#@function list_list
#@ - list of indigen shortcuts types
list_list() {
  echo -e "  \E[1mList Types:\E[0m\n"
  declare -F|cut -d' ' -f3|sed -n 's/^list_/    /p'
  echo -e "\n  \E[1mSee Also:\E[0m\n"
  echo -e "    $CALL help\n"
}

#@function list_help
#@ - list of indigen help topics
list_help() {
  echo -e "  \E[1mHelp Topics:\E[0m\n"
  ls $DIR_HELP | xargs -I {} echo "    {}"
  echo -e "\n  \E[1mSee Also:\E[0m\n"
  echo -e "    $CALL list\n"
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
  echo -e "  \E[1mBuild Targets:\E[0m"
  (cd $DIR_CONF; find . -maxdepth 1 -type d|sed -e 's/^\./   /' -e 's/\// /g')|sort
  echo
}

#@function list_stage
#@ - list stage configuration
list_stage() {
  list_stages
  list_targets
}

#@function list_stages
#@ - list of indigen build stages
list_stages() {
  echo -e "  \E[1mBuild Stages:\E[0m"
  echo
  ls $DIR_STGS | xargs -I {} echo "    {}"
  echo
}

#@function list_commands
#@ - list of indigen commands
list_commands() {
  echo -e "  \E[1mIndigen Commands:\E[0m"
  show_docs call $CALL "$DIR_CMDS/*"
  echo
}

#@function list_functions
#@ - list of indigen functions
list_functions() {
  echo -e "  \E[1mInternal Functions:\E[0m"
  show_docs function "" "$CALL $DIR_LIBS/*"
  echo
}

#@function list_packages
#@ - list packages
list_packages() {
  echo -e "  \E[1mBuild Packages:\E[0m\n"
  (cd $DIR_CONF; find ./ -type f -exec basename {} \;) |sort -u|grep -v build|sed -e 's/\.conf//' -e 's/^/    /'
  echo
}

#@function only_list
#@ - show a computer readable list
only_list() {
  list_$1 | sed 's/^\s*//' | tail --lines=+3 | head --lines=-1
}
