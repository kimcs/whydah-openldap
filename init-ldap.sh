#!/usr/bin/env bash


#
# The main function where program execution begin and end
#

function main {
DOMAINBASE=$(capture_domainbase)
ADMINUSERNAME=$(capture_username "Enter username of openldap super user: ")
ADMINPASSPLAIN=$(capture_plaintext_password)
ADMINPASSWORD=$(slappasswd -h {SSHA} -s "$ADMINPASSPLAIN")
UIBUSERNAME=$(capture_username "Enter username of uib admin user: ")
UIBPASSWORD=$(capture_hashed_password "Enter username of uib admin user: ")

echo DOMAINBASE=$DOMAINBASE
echo ADMINUSERNAME=$ADMINUSERNAME
echo ADMINPASSWORD=$ADMINPASSWORD
echo UIBUSERNAME=$UIBUSERNAME
echo UIBPASSWORD=$UIBPASSWORD

mkdir -p ldifs

create_admin_ldif $DOMAINBASE $ADMINUSERNAME $ADMINPASSWORD
create_uibadmin_ldif $DOMAINBASE $UIBUSERNAME $UIBPASSWORD
create_uibadmin-acl_ldif $DOMAINBASE $UIBUSERNAME $ADMINUSERNAME

ldapmodify -Y EXTERNAL -H ldapi:/// -f ldifs/admin.ldif && \
ldapadd -x -D cn=$ADMINUSERNAME,$DOMAINBASE -w "$ADMINPASSPLAIN" -f ldifs/uibadmin.ldif &&\
ldapmodify -Y EXTERNAL -H ldapi:/// -f ldifs/uibadmin-acl.ldif
}


#
# Helper functions and a call to main at bottom
#


function capture_domainbase {
read -p "Enter new domain: " domain
echo dc=$(echo $domain|sed s/[.]/,dc=/g)
}

function capture_username {
read -p "$1" username
echo $username
}

function capture_plaintext_password {
while :
do
  read -s -p "New password: " plaintextpass
  echo "" >&2
  read -s -p "Re-enter new password: " replaintextpass
  echo "" >&2
  if [[ "$plaintextpass" == "$replaintextpass" ]]; then
    break
  else
    echo Re-entered password does not match, please try again. >&2
  fi
done
echo $plaintextpass
}

function  capture_hashed_password {
while :
do
  hashed_password=$(slappasswd -h {SSHA})
  if [ $? -eq 0 ]; then
    break
  fi
done
echo $hashed_password
}

function create_admin_ldif {
cat <<EOF > ldifs/admin.ldif
dn:  olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $1
-
replace: olcRootDN
olcRootDN: cn=$2,$1
-
replace: olcRootPW
olcRootPW: $3
EOF
}

function create_uibadmin_ldif {
cat <<EOF > ldifs/uibadmin.ldif
version: 1

dn: $1
objectClass: top
objectClass: extensibleObject
objectClass: domain

dn: ou=users,$1
objectClass: top
objectClass: organizationalUnit
ou: users

dn: cn=$2,ou=users,$1
objectClass: top
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
cn: $2 
sn: $2
givenName: $2
initials: $2
uid: $2
userPassword: $3
EOF
}

function create_uibadmin-acl_ldif {
cat <<EOF > ldifs/uibadmin-acl.ldif
dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange
  by self write 
  by anonymous auth 
  by dn="cn=admin,@DOMAINBASE@" write
  by dn="cn=$2,ou=administrators,$1" write 
  by * none 
olcAccess: {1}to dn.base=""
  by * read
olcAccess: {2}to dn.subtree="ou=users,$1"
  by self write 
  by dn="cn=$2,ou=administrators,$1" write 
  by * read
olcAccess: {3}to * 
  by self write 
  by dn="cn=$3,$1" write 
  by * read
EOF
}

main

