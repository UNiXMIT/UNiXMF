FROM redhat/ubi9-init:latest
EXPOSE 389 636
ENV SLAPPASS=strongPassword123
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm; \
    dnf install openldap-servers openldap-clients unzip -y; \
    dnf clean all; \
    mkdir -m 775 /openldap; \
    mkdir -m 775 /openldap/config; \
    mkdir -m 775 /openldap/log; \
    cd /openldap; \
    curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/openldap/schema.zip; \
    unzip schema.zip; \
    pkill slapd; \
    sed -i '/CRC.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    sed -i '/olcAccess:.*/c\olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    sed -i '/ ,cn=auth.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif; \
    /usr/sbin/slapd -u ldap -h ldap:/// ldaps:/// ldapi:///; \
    SECRET=$(slappasswd -s $SLAPPASS); \
    sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" /openldap/schema/chrootpwd.ldif; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /openldap/schema/chrootpwd.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/corba.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/duaconf.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/java.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/misc.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/collective.ldif > /dev/null 2>&1; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /openldap/schema/ppolicy.ldif > /dev/null 2>&1; \
    sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" /openldap/schema/backend.ldif; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /openldap/schema/backend.ldif > /dev/null 2>&1; \
    pkill slapd; \
    cp /etc/openldap/schema/* /openldap/schema/; \
    rm -rf /openldap/config/*; \
    cd /openldap/schema; \
    slaptest -f /openldap/schema/schema_convert.conf -F /openldap/config; \
    cp /openldap/config/cn=config/cn=schema/cn={12}container.ldif /etc/openldap/slapd.d/cn=config/cn=schema; \
    cp /openldap/config/cn=config/cn=schema/cn={13}mfds.ldif /etc/openldap/slapd.d/cn=config/cn=schema; \
    chown -R ldap /etc/openldap/slapd.d; \
    chmod -R 700 /etc/openldap/slapd.d; \
    /usr/sbin/slapd -u ldap -h ldap:/// ldaps:/// ldapi:///; \
    systemctl enable slapd; \
    rm -rf /openldap/log/*; \
    ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/schema/top.ldif -H ldapi:/// > /openldap/log/top.log; \
    ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/schema/mf-containers.ldif -H ldapi:/// > /openldap/log/mf-containers.log; \
    ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/schema/mfds-users.ldif -H ldapi:/// -c > /openldap/log/mfds-users.log; \
    ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f /openldap/schema/es_default_ldap_openldap.ldif -H ldapi:/// -c > /openldap/log/es_default_ldap_openldap.ldif; \
    ldapsearch -H ldapi:/// -x -b "cn=subschema" -s base + > /openldap/log/schema.log
CMD ["/sbin/init"]