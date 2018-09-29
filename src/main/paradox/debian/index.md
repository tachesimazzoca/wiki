# Debian

## Cheat Sheet

### Setting Locales

```sh
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LC_CTYPE = "ja_JP.UTF-8",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").

$ sudo apt-get install task-japanese

# uncomment desired locales
$ sudo vim /etc/locale.gen
...
# ja_JP.EUC-JP EUC-JP
ja_JP.UTF-8 UTF-8
# ka_GE GEORGIAN-PS
...

$ sudo locale-gen
$ sudo update-locale LANG=en_US.UTF-8
```
