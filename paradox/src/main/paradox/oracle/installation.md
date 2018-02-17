# Installation

## Downloads

* `http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html`

## Oracle XE 11g Release 2 for Linux x64

* `http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm`

The Oracle XE installer depends on the following packages. Make sure that you have already installed them before the following steps.

* `libaio >= 0.3.104`
* `unzip`
* `bc`

The Oracle XE requires at least 2GB swap space. The command `swapon -s` shows swap usage summary.

    % swapon -s
    Filename        Type    Size  Used  Priority
    /dev/mapper/VolGroup00-LogVol01         partition 1048568 104736  -1

If there is no swap space or the current swap space doesn't have enough size, add another swap space. The following example creates a `/swap` file and then enables it.

    % dd if=/dev/zero of=/swap bs=1M count=2048
    % mkswap /swap
    % swapon /swap

And more, in order to mount the `/swap` file on startup, add its entry to `/etc/fstab`.

    % vi /etc/fstab
    ....
    /swap swap swap defaults 0 0

Make sure that the server can resolve an IP address to the assigned `HOSTNAME`. For instance, by default, any Amazon Linux servers on AWS VPC might not have an IP entry to the host name `ip-xxx-xxx-xxx-xxx`.

    % vi /etc/hosts
    127.0.0.1   localhost localhost.localdomain
    127.0.0.1   ip-10-0-1-23

Now install the rpm package and then issue the service script `oracle-xe configure`.

    % rpm -ivh oracle-xe-11.2.0-1.0.x86_64.rpm
    % /etc/init.d/oracle-xe configure

To uninstall the package, just use the command `rpm -e <package>`.

    % rpm -e oracle-xe-11.2.0-1.0.x86_64

The `oracle` user has been created as an administrator, who joins the `dba` group. The user must load the script `bin/oracle_env.sh`  before using any Oracle commands.

    % su - oracle
    % source /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh

In practice, you should add a script to `~/.bash_profile` for later use.

    % cat ~/.bash_profile
    source /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
