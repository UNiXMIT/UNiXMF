#!bin/bash
if [[ -n "${SLAPPWD}" ]]; then
    && SECRET=$(slappasswd -s ${SLAPPWD})
    pkill slapd
    sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" /openldap/schema/newpasswd.ldif
    /usr/sbin/slapd -u ldap -h "ldap:/// ldaps:/// ldapi:///"
    ldapmodify -H ldapi:// -Y EXTERNAL -f /openldap/schema/newpasswd.ldif
    crontab -r
fi