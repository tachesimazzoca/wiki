---
layout: page

title: Libraries
---

## Scala Test

<http://www.scalatest.org>

`build.sbt`:

    libraryDependencies += "org.scalatest" %% "scalatest" % "1.8" % "test"


## twitter/util

<https://github.com/twitter/util>

### util-eval

`build.sbt`:

    libraryDependencies += "com.twitter" % "util-eval" % "5.2.0" withSources()

    resolvers += "Twitter Maven Repository" at "http://maven.twttr.com/"


