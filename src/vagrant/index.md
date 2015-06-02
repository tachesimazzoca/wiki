---
layout: plain

title: Vagrant
---

## Creating a Base Box

Publicly available base boxes usually use a root password of "vagrant".

    % passwd
    Changing password for user root.
    New Unix password: vagrant
    ...

Add `vagrant` user with the [insecure keypair](https://github.com/mitchellh/vagrant/tree/master/keys).

    % useradd vagrant
    % su - vagrant
    $ mkdir .ssh
    $ chmod 700 .ssh
    $ cd .ssh
    $ curl "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub" > authorized_keys
    $ chmod 600 authorized_keys
    $ export HISTSIZE=0
    $ exit

Allow passwordless sudo for the `vagrant` user and remove `requiretty` if it exists.

    % visudo
    ...
    vagrant ALL=(ALL) NOPASSWD: ALL
    ...
    #Default requiretty

Set `UseDNS no` in the SSH server configuration.

    % vi /etc/ssh/sshd_config
    ...
    UseDNS no
    ...

Clear any working files, bash history and so on and then shutdown the VM.

    % yum clean all
    % rm /tmp/*
    % umount /mnt/cdrom
    ...
    % export HISTSIZE=0
    % shutdown -h now

Use the `package` sub-command to create.

    % vagrant package --base "CentOS-6.4-x86_64-minimal" --output /path/to/package.box


## Links

* [Vagrant Documentation](http://docs.vagrantup.com/v2/)

