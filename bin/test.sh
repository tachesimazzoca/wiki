#!/bin/sh

set -e

cd "$(dirname "${0}")"/..

errcode=0

fs=$(find src/main/paradox -name '*.md')

echo "================================================================================"
echo "Trailing spaces must be removed"
echo "================================================================================"
for f in $fs
do
  out=$(egrep -n ' +$' "$f" || true)
  if [ -n "$out" ]; then
    echo "${f}:"
    echo $out
    echo "--------------------------------------------------------------------------------"
    errcode=1
  fi
done
if [ "$errcode" = 0 ]; then
  echo ">> OK"
else
  echo ">> NG"
fi

exit ${errcode}
