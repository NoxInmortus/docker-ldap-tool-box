# Docker-LDAP-Tool-Box

This repository aims to deliver a multi-architecture Docker image for the latest versions of LDAP Tool Box projects.

Each project can enable an LDAP authentication on Apache2 to reach LTB app.

This Docker image is rootless and listen on `*:8080`.

If you wish to contribute or report an issue, please use the GitHub repository : https://github.com/NoxInmortus/docker-ldap-tool-box

## Official NoxInmortus repositories

Find more at :
- https://hub.docker.com/u/noxinmortus
- https://git.tools01.imperium-gaming.fr/public
- https://github.com/NoxInmortus?tab=repositories

## Available Architectures
- amd64
- arm64 (aarch64)
- armv7 (arm)

## DockerHub Image and tags

Image : `noxinmortus/docker-ldap-tool-box`

Available tags :
- `white-pages`
- `service-desk`
- `self-service-password`

The build are always made using the master branch of {`white-pages`,`service-desk`,`self-service-password`}. Each new build tag is erasing the previous one, so there is no tag versioning.

## How to build

Choose one of the LDAP-Tool-Box projects : `white-pages`, `service-desk` or `self-service-password`
```
export LTB_PROJECT=self-service-password
docker build --build-arg LTB_PROJECT=${LTB_PROJECT} -t noxinmortus/docker-ldap-tool-box:${LTB_PROJECT} .
```

## Extended usage and Docker volume

You may want to mount `/usr/share/${LTB_PROJECT}/conf` if you wish to edit manually the main app configuration file.

## Variables

There is common variables and dedicated variables for each application (`white-pages`, `service-desk`, `self-service-password`). Each variable is used in the `config.inc.php`, so check the application configuration file for more details about each parameter.

### Common variables
|Variable|Default|Description|
|-|-|-|
|APACHE_SERVERNAME|`$HOSTNAME`|Vhost servername|
|APACHE_SERVERADMIN|`webmaster@localhost`|Vhost serveradmin|
|APACHE_LDAP_AUTH|`false`|LDAP authentication to access the application|
|APACHE_AUTH_LDAP_URL|`ldap://ldap.example.com/dc=example,dc=com`|LDAP URL for `LDAP_AUTH`|
|APACHE_AUTH_LDAP_BIND_DN|`cn=readonly,dc=exemple,dc=com`|LDAP Bind DN for `LDAP_AUTH`|
|APACHE_AUTH_LDAP_BIND_PWD|`secret`|LDAP Bind password for `LDAP_AUTH`|
|APACHE_AUTH_LDAP_GROUP|`cn=support,ou=groups,dc=example,dc=com`|Restrict access to an LDAP group for `LDAP_AUTH`|
|APACHE_AUTH_LDAP_DEREFERENCE_ALIASES|`never`|Set `AuthLDAPDereferenceAliases` directive|
|APACHE_AUTH_LDAP_BIND_AUTHORITATIVE|`off`|Set `AuthLDAPBindAuthoritative` directive|
|APACHE_TRUST_PROXY_SSL|`false`|Adds `SetEnvIf X-Forwarded-Proto "^https$" HTTPS=on` to apach2 configuration|
|APACHE_AUTH_LDAP_TRUSTED_CA|Undef|Set `LDAPTrustedGlobalCert` directive|
|APACHE_AUTH_LDAP_VERIFY_CERT|`On`|Set `LDAPVerifyServerCert` directive|
|LDAP_DEBUG|`false`|Enable LTB app debug mode|
|LDAP_LANG|`en`|Default LTB app language|
|LDAP_URL|`ldap://localhost`|LDAP URL for LTB app|
|LDAP_STARTTLS|`false`|LDAP starttls for LTB app|
|LDAP_BINDDN|`cn=manager,dc=example,dc=com`|LDAP Bind DN for LTB app|
|LDAP_BINDPW|`secret`|LDAP Bind password for LTB app|
|LDAP_BASE|`dc=example,dc=com`|LDAP base for LTB app|

### white-pages variables
|Variable|Default|Description|
|-|-|-|
|LDAP_USER_BASE|`ou=users`|LDAP user base for White-pages|
|LDAP_USER_FILTER|`(objectClass=inetOrgPerson)`|LDAP user filter for White-pages|
|LDAP_GROUPS_BASE|`ou=groups`|LDAP group base for White-pages|
|LDAP_GROUP_FILTER|Undef|LDAP group filter for White-pages|
|LDAP_SIZE_LIMIT|`100`|White-pages max rows to display|
|LDAP_EDIT_LINK|`http://ldapadmin.example.com/?dn=\{dn\}`|Edit button URL|

### service-desk variables
|Variable|Default|Description|
|-|-|-|
|LDAP_USER_BASE|`ou=users`|LDAP user base for Service-desk|
|LDAP_USER_FILTER|`(objectClass=inetOrgPerson)`|LDAP user filter for Service-Desk|
|LDAP_GROUP_FILTER|Undef|LDAP group filter for Service-Desk|
|LDAP_SIZE_LIMIT|`100`|Service-desk max rows to display|
|LDAP_DEFAULT_PPOLICY|Undef|Service-desk password policy to use (see this [issue](https://github.com/ltb-project/service-desk/issues/32) for details)|

### self-service-password (SSP) variables
|Variable|Default|Description|
|-|-|-|
|LDAP_LOGIN_ATTR|`uid`|SSP login attribute to bind to|
|LDAP_FULLNAME_ATTR|`cn`|SSP fullname attribute to bind to|
|LDAP_FILTER|`(&(objectClass=person)($ldap_login_attribute={login}))`|LDAP filter for SSP|
|LDAP_USE_EXOP_PWD|`false`|LDAP use_exop_passwd option for SSP|
|LDAP_AD_MODE|`false`|Active Directory mode|
|LDAP_HASH|`auto`|Hash mechanism for password|
|LDAP_USE_TOKENS|`false`|Use Tokens|
|LDAP_MAIL_USE_LDAP|`false`|Use LDAP mail attribute|
|LDAP_MAIL_FROM|`admin@example.com`|Who the email should come from|
|LDAP_MAIL_FROM_NAME|`Self Service Password`|Who the email should come from|
|LDAP_MAIL_NOTIFY|`false`|Notify users anytime their password is changed|
|LDAP_MAIL_PROTOCOL|`smtp`||
|LDAP_SMTP_HOST|`localhost`||
|LDAP_SMTP_AUTH|`false`||
|LDAP_SMTP_USER|`''`||
|LDAP_SMTP_PASS|`''`||
|LDAP_SMTP_PORT|`25`||
|LDAP_SMTP_TIMEOUT|`30`||
|LDAP_SMTP_KEEPALIVE|`false`||
|LDAP_SMTP_SECURE|`tls`||
|LDAP_SMTP_AUTOTLS|`true`||
|LDAP_SMTP_ALLOW_SELFSIGNED|`false`|Set `$mail_smtp_options = array('ssl'=>array('verify_peer' => false,'verify_peer_name' => false,'allow_self_signed' => true));` to allow self-signed certificate for your SMTP server|
|LDAP_KEYPHRASE|Autogenerated||
|LDAP_RECAPTCHA|`false`||
|LDAP_RECAPTCHA_PUBLICKEY|Undef||
|LDAP_RECAPTCHA_PRIVATEKEY|Undef||
|LDAP_RECAPTCHA_TYPE|`image`||
|LDAP_DEFAULT_ACTION|`change`||
|LDAP_PWD_MIN_LENGTH|`0`||
|LDAP_PWD_MAX_LENGTH|`0`||
|LDAP_PWD_MIN_LOWER|`0`||
|LDAP_PWD_MIN_UPPER|`0`||
|LDAP_PWD_MIN_DIGIT|`0`||
|LDAP_PWD_MIN_SPECIAL|`0`||
|LDAP_PWD_SPECIAL_CHARS|`^a-zA-Z0-9`||
|LDAP_PWD_FORBIDDEN_CHARS|None||
|LDAP_PWD_NO_REUSE|`true`||
|LDAP_PWD_DIFF_LOGIN|`true`||
|LDAP_PWD_DIFF_LAST_MIN_CHARS|`0`||
|LDAP_PWD_FORBIDDEN_WORDS|Undef||
|LDAP_PWD_FORBIDDEN_LDAP_FIELDS|Undef||
|LDAP_PWD_COMPLEXITY|`0`||
|LDAP_PWDNED_PASSWORDS|`false`||
|LDAP_PWD_SHOW_POLICY|`oneerror`||
|LDAP_PWD_SHOW_POLICY_POS|`above`||

## Sources
- https://github.com/ltb-project
- https://ltb-project.org/documentation
- https://github.com/smarty-php/smarty/tree/master
- https://httpd.apache.org/docs/2.4/mod/mod_authnz_ldap.html
- https://httpd.apache.org/docs/2.4/mod/mod_ldap.html

Lint with :
- https://github.com/hadolint/hadolint
- https://github.com/koalaman/shellcheck

## License
GNU General Public License v3.0 view [LICENSE](LICENSE)
