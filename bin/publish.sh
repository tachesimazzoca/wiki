#!/bin/sh

set -e

cd `dirname ${0}`/..

message="Publish tachesimazzoca/wiki@"`git log --oneline | head -n 1 | awk '{print $1}'`

tmpdir=$TMPDIR
if [ -z "$tmpdir" ];
then
  tmpdir=/tmp/
fi

out=${tmpdir}com.github.tachesimazzoca.wiki.$$

trap "rm -fr $out" 0 1 2

git clone "ssh://github-tachesimazzoca/tachesimazzoca/tachesimazzoca.github.com.git" $out
rm -rf "$out/wiki"
cp -R target/paradox/site/main $out/wiki
cd $out
git config user.name "Takeshi Matsuoka"
git config user.email "tachesimazzoca@gmail.com"
git add wiki

# Check if there are nothing to do
git diff-index --quiet HEAD || modified=1
if [ -z "$modified" ];
then
  echo Nothing to do
  exit 0
fi

git commit -m "${message}"

echo -n "Are you sure?"
read INPUT

case "$INPUT" in
    "y") git push origin master ;;
    *) ;;
esac

exit 0
