---
layout: page

title: Unit Testing
---

## Oracle SQL Developer 4.0

### Add Roles to Unit Test Users

Grant the following privileges to each user.

    grant connect, resource, create view to <user>;

And then create the `UT_REPO_(USER|ADMINISTORATOR)` role and grant it to each user. The wizard of the Oracle SQL Developer will do the same thing if the user doesn't have any privileges to create a new unit test repository.

    create role UT_REPO_ADMINISTRATOR;
    create role UT_REPO_USER;
    grant create public synonym,drop public synonym to UT_REPO_ADMINISTRATOR;
    grant select on dba_role_privs to UT_REPO_USER;
    grant select on dba_role_privs to UT_REPO_ADMINISTRATOR;
    grant select on dba_roles to UT_REPO_ADMINISTRATOR;
    grant select on dba_roles to UT_REPO_USER;
    grant select on dba_tab_privs to UT_REPO_ADMINISTRATOR;
    grant select on dba_tab_privs to UT_REPO_USER;
    grant execute on dbms_lock to UT_REPO_ADMINISTRATOR;
    grant execute on dbms_lock to UT_REPO_USER;
    grant UT_REPO_USER to UT_REPO_ADMINISTRATOR with admin option;
    grant UT_REPO_ADMINISTRATOR to <user> with admin option;

Since the AWS Oracle RDS restricts the master user from using the SYS objects, you need to do the same thing with the `rdsadmin.rdsadmin_util` package if you choose it.

    create role UT_REPO_ADMINISTRATOR;
    create role UT_REPO_USER;
    grant create public synonym,drop public synonym to UT_REPO_ADMINISTRATOR;
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_ROLE_PRIVS', 'UT_REPO_ADMINISTRATOR');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_ROLE_PRIVS', 'UT_REPO_USER');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_ROLES', 'UT_REPO_ADMINISTRATOR');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_ROLES', 'UT_REPO_USER');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TAB_PRIVS', 'UT_REPO_ADMINISTRATOR');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBA_TAB_PRIVS', 'UT_REPO_USER');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOCK', 'UT_REPO_ADMINISTRATOR');
    exec rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOCK', 'UT_REPO_USER');
    grant UT_REPO_USER to UT_REPO_ADMINISTRATOR with admin option;
    grant UT_REPO_ADMINISTRATOR to <user> with admin option;

## utPLSQL

* <http://utplsql.sourceforge.net/>

Each testing user needs the following privileges.

    % sqlplus / as sysdba
    SQL> GRANT execute ON UTL_FILE to public;
    SQL> GRANT execute ON DBMS_PIPE to public;

    SQL> GRANT connect, resource, create view TO <user>;
    SQL> GRANT create public synonym, drop public synonym to <user>;

Download and unzip `plsql-x-x-x.zip`. Then `cd` to the directory that contains the file `ut_i_do.sql`.

    % unzip -d plsql-2-3-0 plsql-2-3-0.zip
    % cd plsql-2-3-0/code
    % sqlplus <user>
    ...
    -- The ut_i_do.sql must be in the current directory.
    SQL> @ut_i_do install;

    -- To uninstall, ...
    SQL> @ut_i_do uninstall;

