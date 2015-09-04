DOMAINBASE=dc=yourdomain,dc=no
ADMINPASSWORD=$(slappasswd -h {SSHA} -s secret)
UIBADMINPASSWORD=secret

cat <<EOF > admin.ldif
dn:  olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: @DOMAINBASE@
-
replace: olcRootDN
olcRootDN: cn=admin,@DOMAINBASE@
-
replace: olcRootPW
olcRootPW: @ADMINPASSWORD@
EOF
sed -i s/@DOMAINBASE@/$DOMAINBASE/ admin.ldif
sed -i "s|@ADMINPASSWORD@|$ADMINPASSWORD|" admin.ldif

cat <<EOF > uibadmin.ldif
version: 1

dn: @DOMAINBASE@
objectClass: top
objectClass: extensibleObject
objectClass: domain

dn: ou=users,@DOMAINBASE@
objectClass: top
objectClass: organizationalUnit
ou: users

dn: cn=uibadmin,ou=users,@DOMAINBASE@
objectClass: top
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
cn: uibadmin 
sn: UIBAdmin
givenName: UIBAdmin
initials: uibadmin
uid: uibadmin
userPassword: @UIBADMINPASSWORD@
EOF
sed -i s/@DOMAINBASE@/$DOMAINBASE/ uibadmin.ldif
sed -i "s|@UIBADMINPASSWORD@|$UIBADMINPASSWORD|" uibadmin.ldif

cat <<EOF > uibadmin-acl.ldif
dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange
  by self write 
  by anonymous auth 
  by dn="cn=admin,@DOMAINBASE@" write
  by dn="cn=uibadmin,ou=administrators,@DOMAINBASE@" write 
  by * none 
olcAccess: {1}to dn.base=""
  by * read
olcAccess: {2}to dn.subtree="ou=users,@DOMAINBASE@"
  by self write 
  by dn="cn=uibadmin,ou=administrators,@DOMAINBASE@" write 
  by * read
olcAccess: {3}to * 
  by self write 
  by dn="cn=admin,@DOMAINBASE@" write 
  by * read
EOF
sed -i s/@DOMAINBASE@/$DOMAINBASE/ uibadmin-acl.ldif

