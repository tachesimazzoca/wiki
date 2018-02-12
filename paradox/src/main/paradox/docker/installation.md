# Installation

## CentOS7

```bash
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
```
