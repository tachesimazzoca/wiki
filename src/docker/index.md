---
layout: plain

title: Docker 
---

## Installation

### CentOS7

{% highlight bash %}
$ su -

$ cat /etc/yum.repos.d/docker.repo
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=0
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg

$ yum install --enablerepo=dockerrepo docker-engine
$ systemctl start docker.service

# When the docker daemon starts, it makes the ownership
# of the Unix socket read/writable by the docker group.
$ useradd -g docker docker

$ su - docker
$ docker run hello-world
{% endhighlight %}

## Docker CLI

* [Use the Docker command line](https://docs.docker.com/v1.11/engine/reference/commandline/cli/)
* [Explore Official Repositories](https://hub.docker.com/explore/)

### Images

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

#### Dockerfile

{% highlight bash %}
$ mkdir /path/to/your/own/image
$ cd /path/to/your/own/image
$ vi Dockerfile
FROM centos:6
RUN yum update && yum install -y postgresql-server && service postgresql initdb
$ docker build .
...
Successfully built d7fc31cb7cec
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
<none>              <none>              d7fc31cb7cec        About a minute ago   305.3 MB
{% endhighlight %}

### Containers

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

## Docker Machine

* [Docker Machine CLI Reference](https://docs.docker.com/v1.11/machine/reference/)

On [Mac OS X](https://docs.docker.com/v1.11/engine/installation/mac/) or [Windows](https://docs.docker.com/v1.11/engine/installation/windows/), you need to launch a Docker host on a virtual machine driver, such as Oracle VirtualBox. You can manage docker hosts with the `docker-machine` command in Docker Toolbox.

### Mac OS X

Just Launching the _Docker Quickstart Terminal.app_ starts the virtual machine `default` having a Docker host and then adds the ENV variables to use the docker command.

`/Applications/Docker/Docker Quickstart Terminal.app/Contents/Resources/Scripts/start.sh` is a nice example for beginners, which shows how to create and launch a Docker host with Oracle VirtualBox.

{% highlight bash %}
# Create a VirtualBox machine named as "default" 
$ docker-machine create -d virtualbox --virtualbox-memory 2048 --virtualbox-disk-size 204800 default
$ docker-machine start default
$ docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.10.2   

# Before using the docker command, you need to add ENV variables referred to the docker machine.
$ docker info
Cannot connect to the Docker daemon. Is the docker daemon running on this host?
$ docker-machine env --shell=bash default
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
...
export DOCKER_MACHINE_NAME="default"
...
$ eval "$(docker-machine env --shell=bash default)"

$ docker info
...

# Explore the virtual machine with SSH
$ docker-machine ssh default

# Stop the virtual machine "default"
$ docker-machine stop default

# Clean up the virtual machine "default"
$ docker-machine rm -f default
$ rm -rf ~/.docker/machine/machines/default
{% endhighlight %}

You would rather set the ENV variables in `~/.bash_profile`.

{% highlight bash %}
$ cat ~/.bash_profile
...
VM_STATUS="$(docker-machine status default 2>&1)"
if [ "${VM_STATUS}" == "Running" ]; then
  eval "$(docker-machine env --shell=bash default)"
fi
{% endhighlight %}

