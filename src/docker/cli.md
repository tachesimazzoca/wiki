---
layout: page

title: Docker CLI
---

## Overview

* [Use the Docker command line](https://docs.docker.com/v1.11/engine/reference/commandline/cli/)
* [Explore Official Repositories](https://hub.docker.com/explore/)

## Images

{% highlight bash %}
{% raw %}
$ docker search centos
...
$ docker pull centos
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              latest              05188b417f30        2 days ago          196.8 MB

$ docker pull centos:5
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              5                   cfbd8d982733        2 days ago          284.7 MB
centos              latest              05188b417f30        2 days ago          196.8 MB

$ docker images --format "{{.ID}}: {{.Repository}}:{{.Tag}}"
cfbd8d982733: centos:5
05188b417f30: centos:latest

# Remove the image "centos:5"
$ docker rmi centos:5
$ docker images --format "{{.ID}}: {{.Repository}}:{{.Tag}}"
05188b417f30: centos:latest
{% endraw %}
{% endhighlight %}

## Containers

{% highlight bash %}
# -t: Allocate a pseudo-TTY
# -i: Keep STDIN open even if not attached
$ docker run -t -i centos /bin/bash
[root@2cbe4afe6840]# uname -r
3.10.0-327.22.2.el7.x86_64
[root@2cbe4afe6840]# exit
exit

# List all conatainers
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS ...
2cbe4afe6840        centos              "/bin/bash"         36 seconds ago      Exited (0) 12 seconds ago ...

# Fetch logs of the container ID:2cbe4afe6840
$ docker logs 2cbe4afe6840
[root@2cbe4afe6840 /]# uname -r
3.10.0-327.22.2.el7.x86_64
[root@2cbe4afe6840 /]# exit
exit

# Stop and then remove the container ID:2cbe4afe6840
$ docker stop 2cbe4afe6840
$ docker rm 2cbe4afe6840
{% endhighlight %}

The `-d` flag tells Docker to run the container in background. To bind the specific ports, use the `-p` option.

{% highlight bash %}
$ docker run -d -p 35432:5432 training/postgres
# or map any ports exposed in the image
$ docker run -d -P --name db training/postgres
$ docker port db
5432/tcp -> 0.0.0.0:32768
{% endhighlight %}

## Volume

The `dangling` filter matches on all volumes not referenced by any containers. With the `quiet` option, you can list only the unused volume names.

{% highlight bash %}
$ docker volume ls -qf dangling=true
{% endhighlight %}

To clean up every unused volume, simply pass those names to the command `xargs docker volume rm`.

{% highlight bash %}
$ docker volume ls -qf dangling=true | xargs docker volume rm
{% endhighlight %}

