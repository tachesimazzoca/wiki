---
layout: page

title: Android Debug Bridge
---

## Overview

* [Android Debug Bridge](http://developer.android.com/tools/help/adb.html)

## Tips

### Dumping system data

You can dump system data to the screen by the command `shell dumpsys`. The output shows lots of information, so you might redirect STDOUT to a text file.

    % adb shell dumpsys > dump.txt
    % less dump.txt
    Currently running services:
      SurfaceFlinger
      accessibility
      account
      activity
      ...

The first section tells about _Currently running services_. If a service name is specified after `dumpsys`, then the other sections are filtered out.

    # Show only "battery"
    % adb shell dumpsys battery
    Current Battery Service state:
      AC powered: true
      USB powered: false
      Wireless powered: false
      ...

### Investigating intent filters

Look up the `Activitiy Resolver Table` section in the output of the command `shell dumpsys package`.

    % adb shell dumpsys package > package.txt
    % less package.txt
    ...
    Activity Resolver Table:
      Full MIME Types:
          application/itunes:
            41adb878 com.android.music/.MediaPlaybackActivity filter 41adb9e0
            ...

