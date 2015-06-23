---
layout: page

title: Logging
---

## syslog

To enable logging from remote machines, add the `-r` option to `SYSLOGD_OPTIONS`.

    % vim /etc/sysconfig/syslog.conf
    # Options to syslogd
    # -m 0 disables 'MARK' messages.
    # -r enables logging from remote machines
    # -x disables DNS lookups on messages recieved with -r
    # See syslogd(8) for more details
    SYSLOGD_OPTIONS="-m 0 -r"

Add a `local?.*` entry to `syslog.conf` and then restart the service _syslog_.

    % cat /etc/haproxy/haproxy.cfg
    global
            log 127.0.0.1   local0
    ...

    % vim /etc/syslog.conf
    ...
    # HAProxy
    local0.*       /var/log/haproxy.log

    % service syslog restart

