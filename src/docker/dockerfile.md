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

