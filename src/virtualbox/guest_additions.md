---
layout: page 

title: Guest Additions
---

## CentOS-5.8-x86_64

Install `kernel-devel` and remove the old (mismatch) `kernel` package:

    % yum list installed | grep kernel
    kernel.x86_64             2.6.18-308.el5
    % yum update
    % yum install kernel-devel
    % yum list installed | grep kernel
    kernel.x86_64             2.6.18-308.el5
    kernel.x86_64             2.6.18-371.3.1.el5
    kernel-devel.x86_64       2.6.18-371.3.1.el5
    % yum remove kernel-2.6.18-308.el5

and then restart the VM to load the updated kernel.

    % uname -r
    2.6.18-308.el5
    % shutdown -r now
    ...
    % uname -r
    2.6.18-371.3.1.el5

For versions prior to 6, add `divider=0 clocksource=acpi_pm` to the kernel boot options.

    % vi /etc/grub.conf
    ....
    title CentOS (2.6.18-371.3.1.el5)
        root (hd0,0)
        kernel /vmlinuz-2.6.18-371.3.1.el5 ro root=/dev/VolGroup00/LogVol00 divider=10 clocksource=acpi_pm
        initrd /initrd-2.6.18-371.3.1.el5.img
    ....
    % shutdown -r now

Install "Development Tools" for gcc/make utilities.

    % yum groupinstall "Development Tools"

Select a menu `VirtualBox VM > Devices > Insert Guest Additions CD image ...` and mount the CD device as `/mnt/cdrom`.

    % mkdir /mnt/cdrom
    % mount -r /dev/cdrom /mnt/cdrom

Execute the script `VBoxLinuxAdditions.run`.

    % cd /mnt/cdrom
    % ./VBoxLinuxAdditions.run

