FROM ubuntu:trusty
MAINTAINER Kim Christian Gaarder <kim.christian.gaarder@gmail.com>

RUN apt-get update && apt-get install -y ldap-server ldap-client ldap-utils
COPY admin.ldif uibadmin.ldif uibadmin-acl.ldif /tmp/ldifs/
RUN service slapd start && \
	ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ldifs/admin.ldif && \
	ldapadd -x -D cn=admin,dc=external,dc=WHYDAH,dc=no -w thesecret -f /tmp/ldifs/uibadmin.ldif &&\
	ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/ldifs/uibadmin-acl.ldif && \
	service slapd stop && \
	sleep 3

EXPOSE 389

CMD ["/usr/sbin/slapd", "-d", "256", "-h", "ldap:/// ldapi:///", "-g", "openldap", "-u", "openldap", "-F", "/etc/ldap/slapd.d"]
