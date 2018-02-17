---
layout: page

title: Tips
---

## Uninstall Oracle XDB

The Oracle XDB uses the 8080 port, so it will causes the conflict with an application using the same port, such as a Tomcat default connector. Even if you aren't working with such applications, you should uninstall it for the security reason unless you need the Oracle XDB.

Search the app directory for `rdbms/admin/catnoqm.sql`, and then issue the SQL on sqlplus.

    % sqlplus / as sysdba
    SQL> @/u01/app/oracle/product/11.2.0/xe/rdbms/admin/catnoqm.sql


## Listener Parameters on EC2-Classic

On AWS EC2-classic, the host name and private IP address assigned to the instance will be changed after re-launching.  In that case, you would rather use `0.0.0.0` as the listener TCP address. That makes the listener listen on any IP address.

    % /etc/init.d/oracle-xe stop
    % vi /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
    ....
    LISTENER =
      (DESCRIPTION_LIST =
        (DESCRIPTION =
          (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_XE))
          (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
        )
      )
    ....
    % /etc/init.d/oracle-xe start

## Solution of ORA-01950: no privileges on tablespace "SYSTEM"

The following SQL adds unlimited quota to the user `foo`.

    SQL> ALTER USER foo QUOTA UNLIMITED ON system;

## Solution of ORA-28002: the password will expire within N days

    % sqlplus foo
    ...
    ERROR:
    ORA-28002: the password will expire within 7 days

    % sqlplus / as sysdba
    ....

    SQL> SELECT username,profile FROM dba_users WHERE username = 'FOO';
    USERNAME                       PROFILE
    ------------------------------ ------------------------------
    ...
    FOO                            DEFAULT

    SQL> SELECT * FROM dba_profiles WHERE profile = 'DEFAULT' AND resource_name = 'PASSWORD_LIFE_TIME';
    PROFILE                        RESOURCE_NAME                    RESOURCE
    ------------------------------ -------------------------------- --------
    LIMIT
    ----------------------------------------
    DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD
    180

    SQL> ALTER PROFILE default LIMIT PASSWORD_LIFE_TIME UNLIMITED;

    SQL> SELECT * FROM dba_profiles WHERE profile = 'DEFAULT' AND resource_name = 'PASSWORD_LIFE_TIME';
    PROFILE                        RESOURCE_NAME                    RESOURCE
    ------------------------------ -------------------------------- --------
    LIMIT
    ----------------------------------------
    DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD
    UNLIMITED

