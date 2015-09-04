# whydah-openldap
Docker build for a basic openldap image that will work with Whydah UIB

# Edit domainbase, adminpassword, uibadminpassword
`$ vi generate-ldifs.sh`

# Regenerate ldifs (will overwrite current ldifs) - requires the slappasswd utility to be installed (part of ldap-server package).
`$ sh generate-ldifs.sh`

# Edit the Dockerfile to match the domainbase and admin password for the ldapadd command
`$ vi Dockerfile `

# Build Docker image
`$ docker build -t openldap:1.0 .`

# Run Docker image
`$ docker run -d -p 389:389 openldap:1.0`

