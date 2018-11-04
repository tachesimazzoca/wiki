#!/bin/sh

set -e

#----------------------------------------------------------
# Build wiki pages
#----------------------------------------------------------
cd resource-wiki
bin/test.sh
sbt paradox
message="Publish tachesimazzoca/wiki@"`git log --oneline | head -n 1 | awk '{print $1}'`

#----------------------------------------------------------
# Update wiki pages on gh-page
#----------------------------------------------------------
cd ..
git clone resource-gh-page updated-gh-page
rm -rf updated-gh-page/wiki
cp -R resource-wiki/target/paradox/site/main updated-gh-page/wiki 

#----------------------------------------------------------
# Commit changes if modified
#----------------------------------------------------------
cd updated-gh-page
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
