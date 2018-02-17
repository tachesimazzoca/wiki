---
layout: page

title: Installation
---

## rpm-build

Make sure the following packages have already been installed.

    % yum install rpm-build pcre-devel gcc

We assume that the `%{_topdir}` is `/usr/src/redhat` in this instruction.

    % rpmbuild --showrc
    ...
    -14: _builddir  %{_topdir}/BUILD
    -14: _rpmdir    %{_topdir}/RPMS
    -14: _sourcedir %{_topdir}/SOURCES
    -14: _specdir   %{_topdir}/SPECS
    -14: _srcrpmdir %{_topdir}/SRPMS
    -14: _topdir    %{_usrsrc}/redhat
    -14: _usr       /usr
    -14: _usrsrc    %{_usr}/src
    ...

Download and extract the source .tar.gz and then copy the spec file `examples/haproxy.spec` into `%{_specdir}`.

    % cd /usr/local/src
    % curl -LO "http://www.haproxy.org/download/1.4/src/haproxy-1.4.26.tar.gz"
    % tar xvfz haproxy-1.4.26.tar.gz
    % cp haproxy-1.4.26/examples/haproxy.spec /usr/src/redhat/SPECS/.
    % cp haproxy-1.4.26.tar.gz /usr/src/redhat/SOURCE/.

Missing `doc/proxy-protcol.txt` in haproxy-1.4.26, you may need to modify the spec file.

    70c70
    < %doc CHANGELOG README examples/*.cfg doc/haproxy-en.txt doc/haproxy-fr.txt doc/architecture.txt doc/configuration.txt doc/proxy-protocol.txt
    ---
    > %doc CHANGELOG README examples/*.cfg doc/haproxy-en.txt doc/haproxy-fr.txt doc/architecture.txt doc/configuration.txt

Run `rpmbuild` with the spec file to build a rpm package and then install it.

    % cd /usr/src/redhat/SPECS
    % rpmbuild -bb haproxy.spec
    % cd RPMS/x86_64
    % ls
    haproxy-1.4.26-1.x86_64.rpm  haproxy-debuginfo-1.4.26-1.x86_64.rpm

    % rpm -ivh haproxy-1.4.26-1.x86_64.rpm

