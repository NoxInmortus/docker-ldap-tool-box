#!/usr/bin/env bash

source /etc/apache2/envvars

set -euo pipefail

# Setup apache2 virtual host
if [ ! -f /etc/apache2/sites-available/000-default.conf ]; then
echo "<VirtualHost *:8080>
   ServerName ${APACHE_SERVERNAME:-$HOSTNAME}
   ServerAdmin ${APACHE_SERVERADMIN:-webmaster@localhost}
   DocumentRoot /usr/share/${LTB_PROJECT}/htdocs
   DirectoryIndex index.php
   AddDefaultCharset UTF-8

   # Used for LTB-SSP only
   Alias /rest /usr/share/${LTB_PROJECT}/rest
   <Directory /usr/share/${LTB_PROJECT}/rest>
      AllowOverride None
      Require all denied
   </Directory>" > /etc/apache2/sites-available/000-default.conf

# LDAP authentication
  if [ "${APACHE_LDAP_AUTH:-false}" == "true" ]; then
    cat >> /etc/apache2/sites-available/000-default.conf << EOF
<Directory /usr/share/${LTB_PROJECT}/htdocs>
  AllowOverride None
  AuthType basic
  AuthName 'LTB ${LTB_PROJECT}'
  AuthBasicProvider ldap
  AuthLDAPURL ${APACHE_AUTH_LDAP_URL:-ldap://ldap.example.com/dc=example,dc=com}
  AuthLDAPBindDN "${APACHE_AUTH_LDAP_BIND_DN:-cn=readonly,dc=exemple,dc=com}"
  AuthLDAPBindPassword "${APACHE_AUTH_LDAP_BIND_PWD:-secret}"
  AuthLDAPDereferenceAliases ${APACHE_AUTH_LDAP_DEREFERENCE_ALIASES:-never}
  AuthLDAPBindAuthoritative ${APACHE_AUTH_LDAP_BIND_AUTHORITATIVE:-off}
  Require ldap-group ${APACHE_AUTH_LDAP_GROUP:-cn=support,ou=groups,dc=example,dc=com}
 </Directory>
EOF
  else
    cat >> /etc/apache2/sites-available/000-default.conf << EOF
<Directory /usr/share/${LTB_PROJECT}/htdocs>
  AllowOverride None
  Require all granted
</Directory>
EOF
  fi

# Misc LDAP options
  if [ ! -f /etc/apache2/mods-enabled/ldap.conf ]; then
    echo "LDAPVerifyServerCert ${APACHE_AUTH_LDAP_VERIFY_CERT:-On}" >> /etc/apache2/mods-enabled/ldap.conf
    if [ -z "${APACHE_AUTH_LDAP_TRUSTED_CA+x}" ]; then
      echo "...ignoring LDAPTrustedGlobalCert (/etc/apache2/mods-enabled/ldap.conf) directive..."
    else
      echo "LDAPTrustedGlobalCert ${APACHE_AUTH_LDAP_TRUSTED_CA}" >> /etc/apache2/mods-enabled/ldap.conf
    fi
  fi

echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
fi

chmod -v 0640 /etc/apache2/sites-available/000-default.conf

if [ ! -f /etc/apache2/mods-enabled/remoteip.conf ]; then
  # Display real client IPs in apache2 logs
  cat >> /etc/apache2/mods-enabled/remoteip.conf << EOF
  RemoteIPHeader X-Forwarded-For
  RemoteIPInternalProxy 127.0.0.1
  RemoteIPInternalProxy 172.16.0.0/12
  RemoteIPInternalProxy 10.0.0.0/8
EOF
  # Let apache know we're behind a TLS reverse proxy
  if [ "${APACHE_TRUST_PROXY_SSL:-false}" == "true" ]; then
  echo 'SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on' >> /etc/apache2/mods-enabled/remoteip.conf
  fi
fi

# ldap.conf options
if [ ! -f /etc/ldap/ldap.conf ]; then
  cat >> /etc/ldap/ldap.conf << EOF
  TLS_CACERT ${LDAP_TLS_CACERT:-/etc/ssl/certs/ca-certificates.crt}
  TLS_REQCERT ${LDAP_TLS_REQCERT:-demand}
EOF
fi

source /"${LTB_PROJECT}".sh

chmod 0440 /usr/share/"${LTB_PROJECT}"/conf/config.inc.php
chown -R www-data:www-data /etc/apache2 /usr/share/"${LTB_PROJECT}"

phplint -w -vvv /usr/share/"${LTB_PROJECT}"/conf/config.inc.php

trap : EXIT TERM INT SIGTERM SIGQUIT SIGWINCH
apachectl -t
apachectl -D FOREGROUND
