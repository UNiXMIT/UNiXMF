#!bin/bash
if [[ -n "$1" ]]; then
    SLAPPASS="$1"
fi
if [[ -n "${SLAPPASS}" ]]; then
    SECRET=$(slappasswd -s ${SLAPPASS})
    pkill slapd
    sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" /openldap/schema/newpasswd.ldif
    /usr/sbin/slapd -u ldap -h "ldap:/// ldaps:/// ldapi:///"
    ldapmodify -H ldapi:// -Y EXTERNAL -f /openldap/schema/newpasswd.ldif
fi