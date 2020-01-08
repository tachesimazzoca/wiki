# Bash

## Parameter Expansion

### Leading match

```bash
# ${parameter#word}: the shortest matching pattern # deleted
$ a="/path/to/jquery.min.js"; echo ${a#*/}
path/to/jquery.min.js
# ${parameter##word}: the longest matching pattern ## deleted
$ a="/path/to/jquery.min.js"; echo ${a##*/}
jquery.min.js
```
### Trailing match

```bash
# ${parameter%word}: the shortest matching pattern % deleted
$ a="/path/to/jquery.min.js"; echo ${a%.*}
/path/to/jquery.min
# ${parameter%%word}: the longest matching pattern %% deleted
$ a="/path/to/jquery.min.js"; echo ${a%%.*}
/path/to/jquery
```

## Recipes

### Emulating readlink

The following script is transcribed from [tomcat80/bin/catalina.sh](https://github.com/apache/tomcat80/blob/trunk/bin/catalina.sh#L119)

```bash
# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`

# Set PGM_HOME to the parent directory of $PRGDIR
PRG_HOME=$(cd "$PRGDIR/.." >/dev/null; pwd)
```

### Incremental counter

```bash
i=0
while [ $i -lt 10 ]
do
  echo $i
  i=$((i+1))
done
```

### Read lines from stdin

```bash
while IFS= read x
do
  echo "|${x}|"
done < '/path/to/file'
```

`IFS=` (Internal Field Separator) keeps leading and trailing spaces of each line.

```bash
$ cat a.txt
foo foo
  bar,  baz

$ cat a.txt | for x in $(cat a.txt); do echo "|${x}|"; done
|foo|
|foo|
|bar,|
|baz|

$ cat a.txt | while read x; do echo "|${x}|"; done
|foo foo|
|bar,  baz|

$ cat a.txt | while IFS= read x; do echo "|${x}|"; done
|foo foo|
|  bar,  baz|
```

### Join rows with a separator

```bash
$ cat a.txt
foo
bar
baz

# -z: Separate lines by NUL characters
$ cat a.txt | sed -z 's/\n/,/g'
foo,bar,baz,
```

