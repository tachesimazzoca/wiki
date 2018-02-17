# GNU Octave

## Overview

* <https://www.gnu.org/software/octave/index.html>

## Installation

### Max OS X

First of all, you need to verify that you have installed X11. X11 is no longer included with OS X, but X11 server and client libraries for OS X are available from the [XQuartz project](http://xquartz.macosforge.org). If not installed X11, download and install an available version of [XQuartz-*.dmg](http://xquartz.macosforge.org/landing/) on the project website.

Here is the Octave wiki page for Max OS X installation: <http://wiki.octave.org/Octave_for_MacOS_X>

This page tells you several ways of using some package managers, but you can find out a binary installer for each Mac OS X version on this site: <http://sourceforge.net/projects/octave/files/Octave%20MacOSX%20Binary/>

#### Mac OS X 10.9

Refer to the section [Binary installer for OSX 10.9.1](http://wiki.octave.org/Octave_for_MacOS_X#Binary_installer_for_OSX_10.9.1)

Octave-cli, which is bundled this binary package, uses Qt (gnuplot_qt) rather than X11 for windowing. You need to put an `~/.octaverc` file, which includes the following line.

```
setenv('GNUTERM', 'qt')
```

#### Mac OS X 10.8 .. 10.5

* Download [octave-3.4.0-i386.dmg](http://sourceforge.net/projects/octave/files/Octave%20MacOSX%20Binary/2011-04-21%20binary%20of%20Octave%203.4.0/) and double-click the `.dmg` to mount the disk image.
* Drag `Octave.app` and `Gnuplot.app`, which is found in the folder extracted `Extras/gnuplot-4.4.3-aqua-i386.dmg`, into the `/Application` folder.
* You can now launch the `/Application/Octave.app`. This will open a Terminal window with the octave REPL.

You might suffer from the following error when you issue the `plot` command in `octave-3.4.0` with `gnuplot-4.4.3-aqua`.

```
octave-3.4.0:1> plot(x, y);
...
Incompatible library version: libfontconfig.1.dylib requires version 18.0.0 or later, but libfreetype.6.dylib provides version 16.0.0
```

The version `gnuplot-4.4.3-aqua` refers to the libraries bundled in itself, the directory of which is `/Application/Gnuplot.app/Contents/Resources/lib`. This error occurs when the `libfreetype.6.dylib` bundled locally is older than the required version. To fix the problem, use the `/usr/X11/lib/libfreetype.6.dylib` as the system library, instead of the local library of Gnuplot.

```
$ cd /Application/Gnuplot.app/Contents/Resources/lib
$ mv libfreetype.6.dylib libfreetype.6.dylib~
$ ln -s /usr/X11/lib/libfreetype.6.dylib
```

## Interpreter

* <http://www.gnu.org/software/octave/doc/interpreter/>
* [Function Index](http://www.gnu.org/software/octave/doc/interpreter/Function-Index.html)

```
octave-3.4.0:1> # Single line comments start with # or %

octave-3.4.0:1> PS1("octave> ")  # Change the current prompt
octave>

octave> 1 + 2
ans =  3

octave> # Ending ; holds to display evaluated values.
octave> 1 + 2;
octave> x = 3;
octave> y = x * 2 + 1
y = 7
octave> y = x ^ 2 + x * 2 + 1;
octave> y
y =  16

octave> # The disp() function displays the value ends with a new line.
octave> disp(x), disp(y)
 3
 16
octave> disp(sprintf("x = %d, y = %.02f", x, y))
x = 3, y = 16.00

octave> whos
Variables in the current scope:

  Attr Name        Size                     Bytes  Class
  ==== ====        ====                     =====  =====
       x           1x1                          8  double
       y           1x1                          8  double

Total is 2 elements using 16 bytes

octave> clear    # Clear all variables
octave> whos

octave> # Working with matrices
octave> X = [1 2 3; 4 5 6; 7 8 9]
X =

   1   2   3
   4   5   6
   7   8   9

octave> X'        # Transpose X with '
ans =

   1   4   7
   2   5   8
   3   6   9

octave> X = [2 3; 4 5]
X =

   2   3
   4   5

octave> X ^ -1    # Inverse X with ^
ans =

  -2.5000   1.5000
   2.0000  -1.0000

octave> inv(X)
ans =

  -2.5000   1.5000
   2.0000  -1.0000

octave> inv(X) * X
ans =

   1   0
   0   1

octave> pinv(X) * X
ans =

   1.0000e+00   1.7764e-15
  -1.7764e-15   1.0000e+00

octave> eye(3)
ans =

Diagonal Matrix

   1   0   0
   0   1   0
   0   0   1

octave> ones(2, 3)
ans =

   1   1   1
   1   1   1

octave> zeros(2, 3)
ans =

   0   0
   0   0
   0   0

```
