#-----------------------------#
# Dockerfile LDAP-Tool-Box    #
# by NoxInmortus              #
#-----------------------------#

FROM debian:buster-slim
LABEL maintainer='NoxInmortus'

ARG LTB_PROJECT

COPY files/ /

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -qy curl openssl ca-certificates gnupg2 \
  && update-ca-certificates --fresh \
  && curl -sSLk --retry 5 https://packages.sury.org/php/apt.gpg | apt-key add - \
  && echo "deb https://packages.sury.org/php/ buster main" | tee /etc/apt/sources.list.d/php.list \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -qy git apache2 php7.4 php7.4-ldap php7.4-mbstring php7.4-curl smarty3 \
  && mv /apache2.conf /etc/apache2/apache2.conf \
  && mv /security.conf /etc/apache2/conf-enabled/security.conf \
  && a2enmod expires headers remoteip deflate ldap authnz_ldap \
  && ln -sfT /dev/stdout "/var/log/apache2/error.log" \
  && ln -sfT /dev/stdout "/var/log/apache2/access.log" \
  && ln -sfT /dev/stdout "/var/log/apache2/other_vhosts_access.log" \
  && git clone --depth 1 --single-branch https://github.com/ltb-project/${LTB_PROJECT}.git /usr/share/${LTB_PROJECT} \
  && chmod +x -v /entrypoint.sh /${LTB_PROJECT}.sh \
  && echo 'Listen 8080' > /etc/apache2/ports.conf \
  && chown -R www-data:www-data /etc/apache2 /usr/share/${LTB_PROJECT} /var/log/apache2 /var/lock/apache2 /var/run/apache2 \
  && rm -rfv /var/www/html /etc/apache2/sites-available/* /usr/share/${LTB_PROJECT}/conf/config.inc.php \
  && rm -rfv /etc/ldap/ldap.conf /etc/apache2/mods-enabled/ldap.conf /etc/apache2/mods-enabled/remoteip.conf \
  && chown -Rv www-data:root /etc/ldap \
  && apt-get remove --purge -qy git curl gnupg2 \
  && apt-get autoremove --purge -qy \
  && apt-get clean \
  && rm -rfv /tmp/* /var/tmp/* /var/lib/apt/lists/* \
  ;

USER www-data
ENV LTB_PROJECT=${LTB_PROJECT}

STOPSIGNAL SIGWINCH
EXPOSE 8080
CMD ["/entrypoint.sh"]
