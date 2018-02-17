# Configuration

## haproxy.cfg

### 1.4.x

    % cat /etc/haproxy/haproxy.cfg
    global
            log 127.0.0.1   local0
            maxconn 4096
            uid 99
            gid 99
            daemon
            #debug
            #quiet
            stats socket /tmp/haproxy.sock user root group wheel level admin

    defaults
            log     global
            mode    http
            option  httplog
            option  dontlognull
            option  redispatch
            retries 3
            maxconn 2000
            contimeout      5000
            clitimeout      50000
            srvtimeout      50000

    listen  app-cluster 0.0.0.0:9000
            cookie  SERVERID rewrite
            balance roundrobin
            server  app1 127.0.0.1:9001 cookie app1 check inter 5000
            server  app2 127.0.0.1:9002 cookie app2 check inter 5000

    % service haproxy check
    % service haproxy start

## Unix Socket Commands

* <http://cbonte.github.io/haproxy-dconv/configuration-1.4.html#9.2>

You can manage the status of haproxy via the UNIX domain socket.

    % cat /etc/haproxy/haproxy.cfg
    global
            ...
            stats socket /tmp/haproxy.sock user root group wheel level admin
    ...

The command _socat_ helps us do that.

    % yum install socat

    % echo "show info" | socat stdio /tmp/haproxy.sock
    % echo "disable server app-cluster/app1" | socat stdio /tmp/haproxy.sock
    % echo "enable server app-cluster/app1" | socat stdio /tmp/haproxy.sock

    # or use interactive mode
    % socat readline /tmp/haproxy.sock
    prompt
    > help
    ...
