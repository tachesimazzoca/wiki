---
layout: page

title: Install
---
## Linux

yum からインストールします。

    % yum install postfix

他MTAを利用中であれば postfix に変更します。

    % /etc/init.d/sendmail stop
    % chkconfig sendmail off

    % alternatives --config mta
    There are 2 programs which provide 'mta'.

      Selection    Command
    -----------------------------------------------
    *+ 1           /usr/sbin/sendmail.sendmail
       2           /usr/sbin/sendmail.postfix

    Enter to keep the current selection[+], or type selection number: 2

`/etc/alternatives/mta*` のリンク先が、postfix に切り替わっていることを確認します。

    % ls -l /etc/alternatives/mta*
    .... /etc/alternatives/mta -> /usr/sbin/sendmail.postfix
    .... /etc/alternatives/mta-aliasesman -> /usr/share/man/man5/aliases.postfix.5.gz
    .... /etc/alternatives/mta-mailq -> /usr/bin/mailq.postfix
    .... /etc/alternatives/mta-mailqman -> /usr/share/man/man1/mailq.postfix.1.gz
    .... /etc/alternatives/mta-newaliases -> /usr/bin/newaliases.postfix
    .... /etc/alternatives/mta-newaliasesman -> /usr/share/man/man1/newaliases.postfix.1.gz
    .... /etc/alternatives/mta-pam -> /etc/pam.d/smtp.postfix
    .... /etc/alternatives/mta-rmail -> /usr/bin/rmail.postfix
    .... /etc/alternatives/mta-sendmail -> /usr/lib/sendmail.postfix
    .... /etc/alternatives/mta-sendmailman -> /usr/share/man/man1/sendmail.postfix.1.gz

postfix を起動します。起動スクリプトにも加えておきます。

    % /etc/init.d/postfix start
    % chkconfig postfix on

ログから postfix が正しく起動できていることを確認します。

    % less /var/log/mailog
