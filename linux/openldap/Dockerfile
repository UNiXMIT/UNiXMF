FROM rockylinux:9
EXPOSE 389
EXPOSE 636
RUN dnf install 'dnf-command(config-manager)' -y; \
    dnf config-manager --set-enabled plus; \
    dnf install openldap-servers openldap-clients python3 openssl -y; \
    dnf clean all
RUN curl -o /usr/bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py; \
    chmod +x /usr/bin/systemctl
RUN mkdir -m 775 /openldap
COPY containerFiles/ /openldap
ENV SLAPPASS=strongPassword
RUN /usr/bin/systemctl start slapd; \
    secret=$(/usr/sbin/slappasswd -s $SLAPPASS); \
    # /usr/bin/sed -i "/olcRootPW:.*/c\olcRootPW: $secret" /openldap/chrootpwd.ldif; \
    # /usr/bin/sed -i '/CRC.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    # /usr/bin/sed -i '/olcAccess:.*/c\olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    /usr/bin/sed -i '/ ,cn=auth.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /openldap/chrootpwd.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/corba.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/duaconf.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/java.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/misc.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/collective.ldif; \
    # /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/ppolicy.ldif; \   Removed in OpenLDAP 2.5 - https://www.openldap.org/doc/admin25/appendix-upgrading.html#ppolicy%20overlay
    /usr/bin/sed -i "/olcRootPW:.*/c\olcRootPW: $secret" /openldap/backend.ldif; \
    /usr/bin/ldapadd -Y EXTERNAL -H ldapi:/// -f /openldap/backend.ldif; \
    /usr/bin/systemctl stop slapd; \
    cp -r /etc/openldap/schema /openldap; \
    rm -rf /openldap/schema/cn=config; \
    cp /openldap/schema_convert.conf /openldap/schema; \
    cp /openldap/mfds.schema /openldap/schema; \
    cp /openldap/container.schema /openldap/schema; \
    mkdir /openldap/config; \
    cd /openldap/schema && /usr/sbin/slaptest -f schema_convert.conf -F /openldap/config; \
    cp /openldap/config/cn=config/cn=schema/cn={11}container.ldif /etc/openldap/slapd.d/cn=config/cn=schema; \
    cp /openldap/config/cn=config/cn=schema/cn={12}mfds.ldif /etc/openldap/slapd.d/cn=config/cn=schema; \
    chown -R ldap /etc/openldap/slapd.d; \
    chmod -R 700 /etc/openldap/slapd.d; \
    /usr/bin/systemctl start slapd; \
    /usr/bin/systemctl enable slapd; \
    mkdir /openldap/log; \
    /usr/bin/ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/top.ldif -h localhost:389 > /openldap/log/top.log; \
    /usr/bin/ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/mf-containers.ldif -h localhost:389 > /openldap/log/mf-containers.log; \
    /usr/bin/ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/mfds-users.ldif -h localhost:389 -c > /openldap/log/mfds-users.log; \
    /usr/bin/sed 's/DC=X/CN=Micro Focus,dc=secldap,dc=com/' /openldap/es_default_ldap_openldap.ldif; \
    /usr/bin/ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/es_default_ldap_openldap.ldif -h localhost:389 -c > /openldap/log/es_default_ldap_openldap.log; \
    /usr/bin/ldapsearch -h localhost:389 -x -b "cn=subschema" -s base + > /openldap/log/schema.log
ENTRYPOINT ["/usr/bin/systemctl", "start", "slapd"]