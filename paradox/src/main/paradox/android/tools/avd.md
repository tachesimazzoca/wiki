# Android Virtual Device

## Overview

* <http://developer.android.com/tools/devices/index.html>

## Emulator Console

* <http://developer.android.com/tools/devices/emulator.html>

To connect to the emulator console, use telnet to connect the console port.

    % telnet localhost 5554

The console of the first emulator uses console port 5554 and ADB port 5555. Subsequent emulators uses port numbers increasing by two:

* `5556/5557`
* `5558/5559`
* ...

### Changing battery capacity state

    % telnet localhost 5554
    ...
    power capacity 100

See more options: <http://developer.android.com/tools/devices/emulator.html#power>

