<a name="unreleased"></a>
## [Unreleased]


<a name="1.0.1"></a>
## 1.0.1 - 2021-03-30
### Added
- Changelog
- RemoteIPInternalProxy 10.0.0.0/8 for docker swarm networks
- hadolint & shellcheck as linter, and corrected Dockerfile and *.sh scripts accordingly
- LDAP Local policy (Self-Service-Password) + remoteip configuration (Apache2)
- feature LDAP_SMTP_ALLOW_SELFSIGNED for SSP

### Changed
- Changes for apache2.conf and entrypoint.sh
- Correct license to have the same as LTB project (GNU General Public License v3.0)
- Improved gitlab ci
- self-service-password behind reverse_proxy by default

### Fixed
- RemoteIPInternalProxy wrong netmask Fixed: APACHE_AUTH_LDAP_TRUSTED_CA option Added: LDAP_TLS_CACERT & LDAP_TLS_REQCERT options Rework gitlab-ci to add ssp-dev
- self-service-password, typo in shell script


[Unreleased]: https://git.tools01.noxinmortus.fr/sysadmins/ansible/role-zabbix/compare/1.0.1...HEAD
