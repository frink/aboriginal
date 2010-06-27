#!/bin/bash

# Iterate through sources/native-builds and run each script, writing output
# to build/control-images/$SCRIPTNAME.hdc

. sources/include.sh || exit 1

mkdir -p build/control-images || dienow
for i in sources/native-builds/*.sh
do
  SCRIPTNAME=$(echo $i | sed 's@.*/\(.*\)\.sh@\1@')
  # Forking doesn't work yet due to extract collisions with the same package
  #maybe_fork "$i build/control-images/$SCRIPTNAME.hdc | maybe_quiet"
  $i build/control-images/$SCRIPTNAME.hdc | maybe_quiet
done
