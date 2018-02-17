---
layout: page

title: Guest Additions
---

## CentOS-5.8-x86_64

If you prefer to keep the 5.8 kernel, you might replace the CentOS base repository with `vault.centos.org/5.8`.

    % vi /etc/yum.repos.d/CentOS-Base.repo
    ...
    [base]
    name=CentOS-5.8 - Base
    baseurl=http://vault.centos.org/5.8/os/$basearch/
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
    ...

Install `kernel-devel` and then restart the VM to load the updated kernel.

    % yum list installed | grep kernel
    kernel.x86_64             2.6.18-308.el5
    % yum update
    % yum install kernel-devel
    % yum list installed | grep kernel
    kernel.x86_64             2.6.18-308.el5
    kernel.x86_64             2.6.18-308.24.1.el5
    kernel-devel.x86_64       2.6.18-308.24.1.el5

    % uname -r
    2.6.18-308.el5
    % shutdown -r now
    ...
    % uname -r
    2.6.18-308.24.1.el5

    # Remove the old (mismatch) `kernel` package.
    % yum remove kernel-2.6.18-308.el5

For versions prior to 6, add `divider=10` to the kernel boot options.

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

