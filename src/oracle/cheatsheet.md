---
layout: page

title: Cheat Sheet
---

## Official Documents

* `http://docs.oracle.com/en/database/database.html`

### Oracle Database Online Documentation 11g Release 2 (11.2)

* `http://docs.oracle.com/cd/E11882_01/nav/portal_4.htm`

## Creating Users

    % sqlplus / as sysdba

    SQL> CREATE USER <username> IDENTIFIED BY <password>
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

    SQL> GRANT CONNECT, RESOURCE TO <user>;

## Describing User Tables

    SQL> DESCRIBE <table>

or issue the following SQL

    SELECT * FROM user_tab_columns
    WHERE
        table_name = <table>
    ORDER BY
        column_id;

The columns of `user_tab_columns` (except for OWNER) are the same as those in `all_tab_columns`.

* `http://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_2103.htm#REFRN20277`

## Describing Roles

    SQL> GRANT CONNECT, RESOURCE TO <role>;
    SQL> GRANT <role> TO <user>;

    -- Select all role names
    SQL> SELECT * FROM dba_roles;

    -- Select privileges of each role
    SQL> SELECT * FROM role_sys_privs WHERE role = 'CONNECT';
    SQL> SELECT * FROM role_sys_privs WHERE role = 'RESOURCE';

    -- Select granted roles of each grantee
    SQL> SELECT * FROM dba_sys_privs WHERE grantee = <role>;
    SQL> SELECT * FROM dba_role_privs WHERE grantee = <user>;

## Selecting Slow Queries

    SELECT * FROM (
        SELECT
            ROUND(cpu_time/executions/1000, 3) AS cpu_time_avg,
            ROUND(elapsed_time/executions/1000, 3) AS elapsed_time_avg,
            executions,
            sql_text
        FROM v$sqlstats
        WHERE executions > 0
        ORDER BY cpu_time_avg DESC
    )
    WHERE rownum <= 50;

## Selecting Locked Sessions

    SELECT
      sid, serial#, sql_address, program, machine
    FROM
      v$session
    WHERE sid IN (
      SELECT sid FROM v$lock WHERE type IN ('TX', 'TM')
    );

    -- Display SQL from v$session.sql_address
    SELECT sql_text FROM v$sqlarea WHERE address = ?;

