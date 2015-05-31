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

    SQL> CREATE ROLE <role>;
    SQL> GRANT CREATE session, CREATE table, CREATE view,
    CREATE procedure, CREATE synonym TO <role>;

    SQL> CREATE USER <username> IDENTIFIED BY <password>
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON users;

    SQL> GRANT <role> TO <username>;

## Describing User Tables

    SQL> DESCRIBE <table>

or issue the following SQL

    SELECT * FROM USER_TAB_COLUMNS
    WHERE
        TABLE_NAME = <table> 
    ORDER BY
        COLUMN_ID;

The columns of `USER_TAB_COLUMNS` (except for OWNER) are the same as those in `ALL_TAB_COLUMNS`.

* `http://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_2103.htm#REFRN20277`

