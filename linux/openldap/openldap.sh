#!/bin/bash
# REQUIREMENTS
# Run as root
# ES Installed, environment set and ESCWA/MFDS running

# DOWNLOAD OpenLDAP SCRIPT
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/openldap/openldap.sh

# DOWNLOAD + EXTRACT SCHEMAS.ZIP
# curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/openldap/schema.zip && unzip schema.zip

while true; do
    read -p "Enterprise Server Security Enabled [Y/N]?: " yn
    case $yn in
        [Yy]*) 
                read -e -p "Enterprise Server User [SYSAD]: " -i "SYSAD" ESUSER
                read -e -p "Enterprise Server Password [SYSAD]: " -i "SYSAD" ESPASS
                ESCWACookie
                break
                ;;  
        [Nn]*) 
                export ESUSER=SYSAD
                export ESPASS=SYSAD
                break
                ;;
    esac
done

dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf -y install openldap openldap-servers openldap-clients openssl
BASEDIR=$(dirname $0)
while true; do
    read -s -p "Password: " SLAPPASS
    printf "\n"
    read -s -p "Confirm Password: " SLAPPASS2
    printf "\n"
    [ "$SLAPPASS" = "$SLAPPASS2" ] && break
    printf 'WARNING: Passwords do not match.\n'
done
# SLAPPASS=strongPassword123
systemctl stop slapd
systemctl disable slapd
rm -rf /etc/openldap/slapd.d
rm -f /var/lib/ldap/*
dnf -y remove openldap-servers > /dev/null 2>&1
dnf -y install openldap-servers > /dev/null 2>&1
sed -i '/CRC.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif
sed -i '/olcAccess:.*/c\olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif
sed -i '/ ,cn=auth.*/d' /etc/openldap/slapd.d/cn=config/olcDatabase={0}config.ldif
systemctl start slapd
SECRET=$(slappasswd -s $SLAPPASS)
sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" $BASEDIR/schema/chrootpwd.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f $BASEDIR/schema/chrootpwd.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/corba.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/duaconf.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/dyngroup.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/java.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/misc.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/openldap.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/collective.ldif > /dev/null 2>&1
ldapadd -Y EXTERNAL -H ldapi:/// -f $BASEDIR/schema/ppolicy.ldif > /dev/null 2>&1
sed -i "/olcRootPW:.*/c\olcRootPW: $SECRET" $BASEDIR/schema/backend.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f $BASEDIR/schema/backend.ldif > /dev/null 2>&1
systemctl stop slapd
cp /etc/openldap/schema/* $BASEDIR/schema/
if [[ -f "$COBDIR/bin/mfds" ]]; then
    $COBDIR/bin/mfds -l "dc=secldap,dc=com" 2 $BASEDIR/schema/mfds.schema > /dev/null 2>&1
elif [[ ! -f "$BASEDIR/schema/mfds.schema" ]]; then
    printf "mfds and $BASEDIR/schema/mfds.schema not found.\n"
    exit 4
fi
mkdir $BASEDIR/config
rm -rf $BASEDIR/config/*
cd $BASEDIR/schema
slaptest -f $BASEDIR/schema/schema_convert.conf -F config
cp config/cn=config/cn=schema/cn={12}container.ldif /etc/openldap/slapd.d/cn=config/cn=schema
cp config/cn=config/cn=schema/cn={13}mfds.ldif /etc/openldap/slapd.d/cn=config/cn=schema
chown -R ldap /etc/openldap/slapd.d
chmod -R 700 /etc/openldap/slapd.d
systemctl start slapd
systemctl enable slapd
mkdir $BASEDIR/log
rm -rf $BASEDIR/log/*
ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f $BASEDIR/schema/top.ldif -H ldapi:/// > $BASEDIR/log/top.log
ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f $BASEDIR/schema/mf-containers.ldif -H ldapi:/// > $BASEDIR/log/mf-containers.log
if [[ -f "$COBDIR/bin/mfds" ]]; then
    $COBDIR/bin/mfds -e "cn=Micro Focus,dc=secldap,dc=com" "cn=Enterprise Server Users" "cn=Enterprise Server User Groups" "cn=Enterprise Server Resources" 2 "/openldap/schema/mfds-users.ldif" > /dev/null 2>&1
elif [[ ! -f "$BASEDIR/schema/mfds-users.ldif" ]]; then
    printf "mfds and $BASEDIR/schema/mfds-users.ldif not found.\n"
    exit 5
fi
ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f $BASEDIR/schema/mfds-users.ldif -H ldapi:/// -c > $BASEDIR/log/mfds-users.log
sed 's/DC=X/CN=Micro Focus,dc=secldap,dc=com/' $COBDIR/etc/es_default_ldap_openldap.ldf > $BASEDIR/schema/es_default_ldap_openldap.ldif
sed -i '/,Data/d' $BASEDIR/schema/es_default_ldap_openldap.ldif
ldapadd -v -D "cn=Manager,dc=secldap,dc=com" -w $SLAPPASS -f $BASEDIR/schema/es_default_ldap_openldap.ldif -H ldapi:/// -c > $BASEDIR/log/es_default_ldap_openldap.log
ldapsearch -H ldapi:/// -x -b "cn=subschema" -s base + > $BASEDIR/log/schema.log

curl -X 'POST' \
  'http://localhost:10086/server/v1/config/esm' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "X-Requested-With: API" \
  -H "Origin: http://localhost:10086" \
  -b "cookieFile.txt" \
  -d '{
  "Name": "OpenLDAP",
  "Module": "mldap_esm",
  "ConnectionPath": "localhost:389",
  "AuthorizedID": "cn=Manager,dc=secldap,dc=com",
  "Password": "$(SLAPPASS)",
  "Enabled": true,
  "CacheLimit": 1024,
  "CacheTTL": 600,
  "Config": "[LDAP]\nBASE=cn=Micro Focus,dc=secldap,dc=com\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug",
  "Description": "OpenLDAP ESM"
}'

curl -X 'POST' \
  'http://localhost:10086/native/v1/security/127.0.0.1/86/esm' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "X-Requested-With: API" \
  -H "Origin: http://localhost:10086" \
  -b "cookieFile.txt" \
  -d '{
  "CN": "OpenLDAP",
  "description": "OpenLDAP ESM",
  "mfESMModule": "mldap_esm",
  "mfESMConnectionPath": "localhost:389",
  "mfESMID": "cn=Manager,dc=secldap,dc=com",
  "mfESMPwd": "$(SLAPPASS)",
  "mfESMStatus": "Enabled",
  "mfESMCacheLimit": 1024,
  "mfESMCacheTTL": 600,
  "mfConfig": "[LDAP]\nBASE=cn=Micro Focus,dc=secldap,dc=com\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug"
}'

ESCWACookie() {
    curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" -H "Content-Type: application/json" -c "cookieFile.txt" -d '{"mfUser": "'"${ESUSER}"'","mfPassword": "'"${ESPASS}"'"}' http://localhost:10086/logon
}