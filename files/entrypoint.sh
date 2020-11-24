#!/usr/bin/env bash

source /etc/apache2/envvars

set -euo pipefail

# Setup apache2
if [[ ! -f /etc/apache2/sites-available/000-default.conf ]]; then
echo "<VirtualHost *:8080>
   ServerName ${APACHE_SERVERNAME:-$HOSTNAME}
   ServerAdmin ${APACHE_SERVERADMIN:-webmaster@localhost}

   DocumentRoot /usr/share/${LTB_PROJECT}/htdocs
   DirectoryIndex index.php

   LogLevel warn
   ErrorLog \${APACHE_LOG_DIR}/error.log
   CustomLog \${APACHE_LOG_DIR}/access.log combined" > /etc/apache2/sites-available/000-default.conf

if [ "${APACHE_LDAP_AUTH:-false}" == "true" ]; then
  cat > /etc/apache2/sites-available/000-default.conf << EOF
<Directory /usr/share/${LTB_PROJECT}/htdocs>
  AllowOverride None
  AuthType basic
  AuthName 'LTB ${LTB_PROJECT}'
  AuthBasicProvider ldap
  AuthLDAPURL ${APACHE_AUTH_LDAP_URL:-ldap://ldap.example.com/dc=example,dc=com}
  AuthLDAPBindDN "${APACHE_AUTH_LDAP_BIND_DN:cn=readonly,dc=exemple,dc=com}"
  AuthLDAPBindPassword "${APACHE_AUTH_LDAP_BIND_PWD:secret}"
  AuthLDAPDereferenceAliases ${APACHE_AUTH_LDAP_DEREFERENCE_ALIASES:-never}
  AuthLDAPBindAuthoritative ${APACHE_AUTH_LDAP_BIND_AUTHORITATIVE:-off}
  Require ldap-group ${APACHE_AUTH_LDAP_GROUP:-cn=support,ou=groups,dc=example,dc=com}
 </Directory>" >> /etc/apache2/sites-available/000-default.conf
EOF
fi
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
fi

if [ "${APACHE_TRUST_PROXY_SSL:-false}" == "true" ]; then
  echo 'SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on' > /etc/apache2/mods-enabled/remoteip_ssl.conf
fi

source /${LTB_PROJECT}.sh

chmod 0440 /usr/share/${LTB_PROJECT}/conf/config.inc.php
chown -R www-data:www-data /etc/apache2 /usr/share/${LTB_PROJECT}

trap : EXIT TERM KILL INT SIGKILL SIGTERM SIGQUIT SIGWINCH
apachectl -t
apachectl -D FOREGROUND
