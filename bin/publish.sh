#!/bin/sh

cd `dirname ${0}`/..

message="Publish tachesimazzoca/wiki@"`git log --oneline | head -n 1 | awk '{print $1}'`

out=/tmp/tachesimazzoca.wiki.$$

trap "rm -fr $out" 0 1 2

git clone "git@github.com:tachesimazzoca/tachesimazzoca.github.com.git" $out
rsync -avz --delete src/_site/ $out/wiki/

cd $out
git config user.name "Takeshi Matsuoka"
git config user.email "tachesimazzoca@gmail.com"
git add wiki 

git commit -a -e -m "${message}"

echo -n "Are you sure?"
read INPUT 

case "$INPUT" in
    "y") git push origin master ;;
    *) break ;;
esac

exit 0
