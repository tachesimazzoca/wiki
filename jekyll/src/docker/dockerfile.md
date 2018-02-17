---
layout: page

title: Dockerfile
---

## Overview

{% highlight bash %}
$ cat Dockerfile
FROM nginx
COPY html /usr/share/nginx/html

$ mkdir html
$ echo '<html><body>Hello World<body></html>' > html/index.html

$ docker build -t local/nginx .

...

$ docker run -d -p 8080:80 --name web local/nginx
$ curl "http://$(docker-machine ip default):8080"
<html><body>Hello World<body></html>
{% endhighlight %}

## mysql-server

{% highlight dockerfile %}
FROM centos:6

RUN yum update -y && \
  yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm && \
  yum install -y mysql-server && \
  yum clean all

# Simulate mysql_secure_installation
RUN service mysqld start && echo "\
  DELETE FROM mysql.user WHERE user = 'root' AND host NOT IN ('localhost', '127.0.0.1', '::1'); \
  DELETE FROM mysql.user WHERE user = ''; \
  DELETE FROM mysql.db WHERE db LIKE 'test%'; \
  FLUSH PRIVILEGES;" | mysql -u root

EXPOSE 3306
CMD [ \
  "/usr/sbin/mysqld", \
  "--datadir=/var/lib/mysql", \
  "--socket=/var/lib/mysql/mysql.sock", \
  "--pid-file=/var/run/mysqld/mysqld.pid", \
  "--basedir=/usr", \
  "--user=mysql" \
]
{% endhighlight %}

## php53

{% highlight dockerfile %}
FROM centos:5

RUN yum update -y && \
  yum install -y httpd && \
  yum install -y php53 php53-devel php53-mbstring php53-mysql php53-xml php53-xmlrpc && \
  yum install -y php-pear && \
  yum clean all

COPY files/etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf

EXPOSE 80
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
{% endhighlight %}

## LAMP + sshd

{% highlight dockerfile %}
FROM centos:5

# epel
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

# yum
RUN yum clean all && \
  yum update -y && \
  yum install -y supervisor openssh-server mysql-server httpd && \
  yum install -y php53 php53-devel php53-mbstring php53-mysql php53-xml php53-xmlrpc php-pear && \
  yum clean all

# sshd
RUN service sshd start

# mysqld
RUN service mysqld start && echo "\
  DELETE FROM mysql.user WHERE User = 'root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); \
  DELETE FROM mysql.user WHERE User = ''; \
  DELETE FROM mysql.db WHERE Db LIKE 'test%'; \
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; \
  FLUSH PRIVILEGES;" | mysql -u root && service mysqld stop

# httpd
COPY files/etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf

# supervisor
COPY files/usr/bin/pidproxy /usr/bin/pidproxy
COPY files/etc/supervisord.conf /etc/supervisord.conf

# /root/.ssh/authorized_keys
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY files/root/.ssh/authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

EXPOSE 22 80 3306
CMD ["/usr/bin/supervisord"]
{% endhighlight %}

Docker containers can manage only one process. Using supervisor is one of the solutions to allow us manage one or more processes.

`files/etc/supervisor.conf`:

{% highlight ini %}
[supervisord]
nodaemon=true

[program:sshd]
command=/usr/sbin/sshd -D

[program:httpd]
command=/usr/sbin/httpd -DFOREGROUND

[program:mysqld]
command=/usr/libexec/mysqld
{% endhighlight %}
