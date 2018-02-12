# Vagrant

## Creating a Base Box

Publicly available base boxes usually use `vagrant` as a password for the `root` user.

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
    #Defaults requiretty

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

## Resizing a Volume

* VirtualBox Manager
    1. Extend the capacity of a virtual machine disk.
* Virtual Machine
    1. Add a new Linux LVM partition.
    1. Create a new physical volume in the new partition.
    1. Add the new physical volume to the volume group.
    1. Extend the logical volume.
    1. resize2fs the logical volume.

Halt the target box to be modified before you begin.

    % cd /path/to/<targetbox>
    % vagrant halt

Vagrant uses the `.vmdk` format for virtual machine disks.

    % cd "/path/to/VirtualBoxVMs/<targetbox>"
    % ls
    ... <current>.vmdk

In order to resize the `.vmdk` file, clone into the `.vdi` file and then resize and clone it into another `.vmdk` file.

    % VBoxManage clonehd <current>.vmdk <cloned>.vdi --format vdi
    0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

    % VBoxManage showhdinfo <cloned>.vdi
    ...
    Capacity:       8192 MBytes

    % VBoxManage modifyhd <cloned>.vdi --resize 16384
    0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

    % VBoxManage showhdinfo <cloned>.vdi
    ...
    Capacity:       16384 MBytes

    % VBoxManage clonehd <cloned>.vdi <resized>.vmdk --format vmdk

Replace the current `.vmdk` with the resized `.vmdk`.

    % VBoxManage showvminfo <targetbox>
    ...
    SATA (0, 0): /path/to/VirtualBoxVMs/<targetbox>/<current>.vmdk (UUID: ...)
    ...

    % VBoxManage storageattach <targetbox> \
    --storagectl "SATA" --port 0 --device 0 --type hdd --medium <resized>.vmdk

Wake up the target box again to do the following steps.

    % vagrant up
    % vagrant ssh

Add a new Linux LVM partition using the command `fdisk`.

    % fdisk -l
    Disk /dev/sda
    ...
    /dev/sda1
    /dev/sda2
    ...

    % fdisk /dev/sda

    Command (m for help): n
    Command action
       e   extended
       p   primary partition (1-4)
    p
    Partition number (1-4): 3  # Enter the last partition number as /dev/sda3
    First cylinder (1045-2088, default 1045):
    Using default value 1045
    Last sector, +sectors or +size{K,M,G} (1045-2088, default 2088):
    Using default value 2088

    Command (m for help): p
    ...
    /dev/sda1 ... Linux
    /dev/sda2 ... Linux LVM
    /dev/sda3 ... Linux

    Command (m for help): t
    Partition number (1-4): 3
    Hex code (type L to list codes): 8e # Linux LVM

    Command (m for help): p
    ...
    /dev/sda1 ... Linux
    /dev/sda2 ... Linux LVM
    /dev/sda3 ... Linux LVM

    Command (m for help): w

    % shutdown -r now

Create and add a new physical volume into the volume group.

    % pvdisplay
    ...
    PV Name               /dev/sda2

    % pvcreate /dev/sda3
    Physical volume "/dev/sda3" successfully created

    % pvdisplay
    ...
    PV Name               /dev/sda2
    ...
    PV Name               /dev/sda3
    ...

    % vgdisplay
    --- Volume group ---
    VG Name               VolGroup
    ...
    VG Size               7.51 GiB
    PE Size               4.00 MiB
    ...
    Free  PE / Size       0 / 0

    % vgextend VolGroup /dev/sda3
    Volume group "VolGroup" successfully extended

    % vgdisplay
    --- Volume group ---
    VG Name               VolGroup
    ...
    VG Size               15.50 GiB
    PE Size               4.00 MiB
    ...
    Free  PE / Size       2046 / 7.99 GiB

Extend the logical volume to the size `Free PE * PE Size`.

    % lvdisplay
    --- Logical volume ---
    LV Path                /dev/VolGroup/lv_root
    ...
    LV Size                6.71 GiB

    # 2046(Free PE) * 4.00(PE Size) = 8184
    % lvextend -L +8184 /dev/VolGroup/lv_root
    Logical volume lv_root successfully resized

    % lvdisplay
    --- Logical volume ---
    LV Path                /dev/VolGroup/lv_root
    ...
    LV Size                14.70 GiB

Use `resize2fs` to apply the logical volume size on the file system.

    % resize2fs -f /dev/VolGroup/lv_root

## Closing Detached Media

    % VBoxManage list hdds
    ...
    % VBoxManage closemedium disk <UUID>

## Links

* [Vagrant Documentation](http://docs.vagrantup.com/v2/)

