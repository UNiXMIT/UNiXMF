# Generating OpenLDAP Schemas

#### Home > Enterprise Developer 11.0 for Eclipse (UNIX) > Rocket® Enterprise Developer 11.0 for Eclipse (UNIX) > Deployment > Configuration and Administration > Enterprise Server Security > Securing an Enterprise Server Installation > Configuring Security Using OpenLDAP > Configuring the OpenLDAP server

#### chrootpwd.ldif
```
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}aQnD1820rdddRAF61fhxZdA/X+pqNamd
```

#### backend.ldif
```
dn: olcDatabase={3}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {3}mdb
olcDbDirectory: /var/lib/ldap
olcDbIndex: objectClass eq,pres
olcDbIndex: ou,cn,mail,surname,givenname eq,pres,sub
olcSuffix: dc=secldap,dc=com
olcRootDN: cn=Manager,dc=secldap,dc=com
olcRootPW: {SSHA}/MYmg3J7nJbzxWPle4zYWhU47WD6TB+w
olcAccess: {0}to attrs=userPassword,shadowLastChange by dn="cn=Manager,dc=secldap,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=secldap,dc=com" write by * read
```

#### mfds.schema
```
mfds -l "dc=secldap,dc=com" 2 mfds.schema
```

#### top.ldif
```
dn: dc=secldap,dc=com
objectClass: dcObject
objectClass: organization
dc: secldap
description: secldap domain
o: MFSECLDAP
```

####  mf-containers.ldif
```
dn: cn=Micro Focus,dc=secldap,dc=com
cn: Micro Focus
objectClass: container
 
dn: cn=Enterprise Server Resources,cn=Micro Focus,dc=secldap,dc=com
cn: Enterprise Server Resources
objectClass: container
 
dn: cn=Enterprise Server Users,cn=Micro Focus,dc=secldap,dc=com
cn: Enterprise Server Users
objectClass: container
 
dn: cn=Enterprise Server User Groups,cn=Micro Focus,dc=secldap,dc=com
cn: Enterprise Server User Groups
objectClass: container
```

#### mfds-users.ldif
```
mfds -e "cn=Micro Focus,dc=secldap,dc=com" "cn=Enterprise Server Users" "cn=Enterprise Server User Groups" "cn=Enterprise Server Resources" 2 "mfds-users.ldif" 
```

#### es_default_ldap_openldap.ldf
```
sed 's/DC=X/CN=Micro Focus,dc=secldap,dc=com/' /opt/microfocus/EnterpriseDeveloper/etc/es_default_ldap_openldap.ldf > schema/es_default_ldap_openldap.ldif
```