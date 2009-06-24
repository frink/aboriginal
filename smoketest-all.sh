#!/bin/bash

if [ "$1" == "--logs" ]
then
  for i in build/smoketest-*.txt
  do
    NAME="$(echo $i | sed 's/smoketest-\(.*\)\.txt/\1/')"
    echo -n "Testing $NAME:"
    RESULT="$(grep 'Hello world!' "$i")"
    [ -z "$RESULT" ] && echo "FAIL" || echo "PASS"
  done

  exit
fi

# Test all targets to see whether or not they can compile and run "hello world"

ls -pd build/system-image-* | sed -n 's@.*/system-image-\(.*\)/@\1@p' | while read i
do
  echo -n "Testing $i:"
  RESULT="$(./smoketest.sh "$i" 2>&1 | grep 'Hello world!')"
  [ -z "$RESULT" ] && echo "FAIL" || echo "PASS"
  rm -f build/system-image-"$i"/hdb.img 2>/dev/null
done
