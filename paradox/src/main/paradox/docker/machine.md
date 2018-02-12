# Docker Machine

## Overview

* [Docker Machine CLI Reference](https://docs.docker.com/v1.11/machine/reference/)

On [Mac OS X](https://docs.docker.com/v1.11/engine/installation/mac/) or [Windows](https://docs.docker.com/v1.11/engine/installation/windows/), you need to launch a Docker host on a virtual machine driver, such as Oracle VirtualBox. You can manage docker hosts with the `docker-machine` command in Docker Toolbox.

## Mac OS X

Just Launching the _Docker Quickstart Terminal.app_ starts the virtual machine `default` having a Docker host and then adds the ENV variables to use the `docker` command.

`/Applications/Docker/Docker Quickstart Terminal.app/Contents/Resources/Scripts/start.sh` is a nice example for beginners, which shows how to create and launch a Docker host with Oracle VirtualBox.

```bash
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
```

You would rather set the ENV variables in `~/.bash_profile` than evaluates them manually each login.

```bash
$ cat ~/.bash_profile
...
VM_STATUS="$(docker-machine status default 2>&1)"
if [ "${VM_STATUS}" == "Running" ]; then
  eval "$(docker-machine env --shell=bash default)"
fi
```

The command `docker-machine stop` stops the virtual machine managing the docker daemon, so that all the containers will be stopped. That means you need to restart each container even after restarting the docker machine or add some scripts to start containers.

Fortunately, on the `virtualbox` driver, the VirtualBox Manager allows you to save the machine state.

```bash
# Save the machine state for the sake of later use
$ VBoxManage controlvm default savestate
# Restart the machine when needed
$ docker-machine start && eval "$(docker-machine env default)"
```
