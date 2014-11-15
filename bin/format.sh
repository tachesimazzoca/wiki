#!/bin/sh

cd `dirname ${0}`/..

fs=`find src -name '*.md'`

for f in $fs
do
  out="${f}.format~"
  cat $f | sed -e 's/ *$//g' > $out
  mv $out $f
done
