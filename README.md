# whydah-openldap
Docker build for a basic openldap image that will work with Whydah UIB

ldifs can be regenerated by running the generate-ldifs.sh script. It requires access to the slappasswd utility which comes with the ldap-server package.

Run 'docker build .' to build an image with a basic openldap setup.
