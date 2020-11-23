# Docker-LDAP-Tool-Box

This repository aims to deliver a multi-architecture Docker image for the latest versions of LDAP Tool Box projects.

Each project can enable an LDAP authentication on Apache2 to reach LTB apps.

This Docker image is rootless and listen on `*:8080`.

## Official NoxInmortus repositories

Find more at :
- https://hub.docker.com/u/noxinmortus
- https://git.tools01.imperium-gaming.fr/public
- https://github.com/NoxInmortus?tab=repositories

## Available Architectures
- amd64
- arm64 (aarch64)
- armv7 (arm)

## How to build

Choose one of the LDAP-Tool-Box projects : white-pages, service-desk, self-service-password
```
export LTB_PROJECT=self-service-password
docker build --build-arg LTB_PROJECT=${LTB_PROJECT} -t noxinmortus/docker-ldap-tool-box:${LTB_PROJECT} .
```

## Extended usage and Docker volume

You may want to mount `/usr/share/${LTB_PROJECT}/conf` if you wish to edit manually the main app configuration file.

## Common Variables
|Variable|Default|
|-|-|
|APACHE_SERVERNAME|`$HOSTNAME`|
|APACHE_SERVERADMIN|`webmaster@localhost`|
|APACHE_LDAP_AUTH|false|
|APACHE_AUTH_LDAP_URL|`ldap://ldap.example.com/dc=example,dc=com`|
|APACHE_AUTH_LDAP_BIND_DN|`cn=readonly,dc=exemple,dc=com`|
|APACHE_AUTH_LDAP_BIND_PWD|`secret`|
|APACHE_AUTH_LDAP_GROUP|`cn=support,ou=groups,dc=example,dc=com`|
|APACHE_AUTH_LDAP_DEREFERENCE_ALIASES|`never`|
|APACHE_AUTH_LDAP_BIND_AUTHORITATIVE|`off`|
|APACHE_TRUST_PROXY_SSL|`false`|
|LDAP_DEBUG|`false`|
|LDAP_LANG|`en`|
|LDAP_URL|`ldap://localhost`|
|LDAP_STARTTLS|`false`|
|LDAP_BINDDN|`cn=manager,dc=example,dc=com`|
|LDAP_BINDPW|`secret`|
|LDAP_BASE|`dc=example,dc=com`|

## white-pages Variables

|LDAP_USER_BASE|`ou=users`|
|LDAP_USER_FILTER|`(objectClass=inetOrgPerson)`|
|LDAP_GROUPS_BASE|`ou=groups`|
|LDAP_GROUP_FILTER|Undef|
|LDAP_SIZE_LIMIT|`100`|
|LDAP_EDIT_LINK|`http://ldapadmin.example.com/?dn=\{dn\}`|

# service-desk Variables
|LDAP_USER_BASE|`ou=users`|
|LDAP_USER_FILTER|`(objectClass=inetOrgPerson)`|
|LDAP_GROUP_FILTER|Undef|
|LDAP_SIZE_LIMIT|`100`|
|LDAP_DEFAULT_PPOLICY|Undef|

# self-service-password Variables
|LDAP_LOGIN_ATTR|`uid`|
|LDAP_FULLNAME_ATTR|cn`|
|LDAP_FILTER|`(&(objectClass=person)($ldap_login_attribute={login}))'`|
|LDAP_USE_EXOP_PWD|`false`|
|LDAP_AD_MODE|`false`|
|LDAP_HASH|`auto`|
|LDAP_USE_TOKENS|`false`|
|LDAP_MAIL_USE_LDAP|`false`|
|LDAP_MAIL_FROM|admin@example.com`|
|LDAP_MAIL_FROM_NAME|`Self Service Password`|
|LDAP_MAIL_NOTIFY|`false`|
|LDAP_MAIL_PROTOCOL|`smtp`|
|LDAP_SMTP_HOST|`localhost`|
|LDAP_SMTP_AUTH|`false`|
|LDAP_SMTP_USER|`''`|
|LDAP_SMTP_PASS|`''`|
|LDAP_SMTP_PORT|`25`|
|LDAP_SMTP_TIMEOUT|`30`|
|LDAP_SMTP_KEEPALIVE|`false`|
|LDAP_SMTP_SECURE|`tls`|
|LDAP_SMTP_AUTOTLS|`true`|
|LDAP_KEYPHRASE|Autogenerated|
|LDAP_RECAPTCHA|`false`|
|LDAP_RECAPTCHA_PUBLICKEY|Undef|
|LDAP_RECAPTCHA_PRIVATEKEY|Undef|
|LDAP_RECAPTCHA_TYPE|`image`|
|LDAP_DEFAULT_ACTION|`change`|

## Sources
- https://github.com/ltb-project
- https://ltb-project.org/documentation
- https://github.com/smarty-php/smarty/tree/master
- https://httpd.apache.org/docs/2.4/mod/mod_authnz_ldap.html

## License
MIT view [LICENSE](LICENSE)
