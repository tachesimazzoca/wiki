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