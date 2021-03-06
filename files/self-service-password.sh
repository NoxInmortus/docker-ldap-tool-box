#!/usr/bin/env bash
set -euo pipefail

if [ -z "${LDAP_KEYPHRASE+x}" ]; then
  LDAP_KEYPHRASE=$(openssl rand -base64 20)
  echo "...generating temporary LDAP_KEYPHRASE."
fi

if [[ ! -f /usr/share/"${LTB_PROJECT}"/conf/config.inc.php ]]; then
  cat > /usr/share/"${LTB_PROJECT}"/conf/config.inc.php << EOF
<?php
#==============================================================================
# LTB Self Service Password
#
# Copyright (C) 2009 Clement OUDOT
# Copyright (C) 2009 LTB-project.org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# GPL License: http://www.gnu.org/licenses/gpl.txt
#
#==============================================================================

#==============================================================================
# All the default values are kept here, you should not modify it but use
# config.inc.local.php file instead to override the settings from here.
#==============================================================================

#==============================================================================
# Configuration
#==============================================================================

# Debug mode
# true: log and display any errors or warnings (use this in configuration/testing)
# false: log only errors and do not display them (use this in production)
\$debug = ${LDAP_DEBUG:-false};

# LDAP
\$ldap_url = "${LDAP_URL:-ldap://localhost}";
\$ldap_starttls = ${LDAP_STARTTLS:-false};
\$ldap_binddn = "${LDAP_BINDDN:-cn=manager,dc=example,dc=com}";
\$ldap_bindpw = "${LDAP_BINDPW:-secret}";
\$ldap_base = "${LDAP_BASE:-dc=example,dc=com}";
\$ldap_login_attribute = "${LDAP_LOGIN_ATTR:-uid}";
\$ldap_fullname_attribute = "${LDAP_FULLNAME_ATTR:-cn}";
\$ldap_filter = "${LDAP_FILTER:-(&(objectClass=person)(\$ldap_login_attribute={login\}))}";
\$ldap_use_exop_passwd = ${LDAP_USE_EXOP_PWD:-false};
\$ldap_use_ppolicy_control = ${LDAP_USE_PPOLICY_CONTROL:-false};

# Active Directory mode
# true: use unicodePwd as password field
# false: LDAPv3 standard behavior
\$ad_mode = ${LDAP_AD_MODE:-false};
# Force account unlock when password is changed
\$ad_options['force_unlock'] = false;
# Force user change password at next login
\$ad_options['force_pwd_change'] = false;
# Allow user with expired password to change password
\$ad_options['change_expired_password'] = false;

# Samba mode
# true: update sambaNTpassword and sambaPwdLastSet attributes too
# false: just update the password
\$samba_mode = false;
# Set password min/max age in Samba attributes
#\$samba_options['min_age'] = 5;
#\$samba_options['max_age'] = 45;
#\$samba_options['expire_days'] = 90;

# Shadow options - require shadowAccount objectClass
# Update shadowLastChange
\$shadow_options['update_shadowLastChange'] = false;
\$shadow_options['update_shadowExpire'] = false;

# Shadow options - require shadowAccount objectClass
# Update shadowLastChange
\$shadow_options['update_shadowLastChange'] = false;
\$shadow_options['update_shadowExpire'] = false;

# Default to -1, never expire
\$shadow_options['shadow_expire_days'] = -1;

# Hash mechanism for password:
# SSHA, SSHA256, SSHA384, SSHA512
# SHA, SHA256, SHA384, SHA512
# SMD5
# MD5
# CRYPT
# clear (the default)
# auto (will check the hash of current password)
# This option is not used with ad_mode = true
\$hash = "${LDAP_HASH:-auto}";

# Prefix to use for salt with CRYPT
\$hash_options['crypt_salt_prefix'] = "\$6\$";
\$hash_options['crypt_salt_length'] = "6";

# Local password policy
# This is applied before directory password policy
# Minimal length
\$pwd_min_length = ${LDAP_PWD_MIN_LENGTH:-0};
# Maximal length
\$pwd_max_length = ${LDAP_PWD_MAX_LENGTH:-0};
# Minimal lower characters
\$pwd_min_lower = ${LDAP_PWD_MIN_LOWER:-0};
# Minimal upper characters
\$pwd_min_upper = ${LDAP_PWD_MIN_UPPER:-0};
# Minimal digit characters
\$pwd_min_digit = ${LDAP_PWD_MIN_DIGIT:-0};
# Minimal special characters
\$pwd_min_special = ${LDAP_PWD_MIN_SPECIAL:-0};
# Definition of special characters
\$pwd_special_chars = "${LDAP_PWD_SPECIAL_CHARS:-^a-zA-Z0-9}";
# Forbidden characters
\$pwd_forbidden_chars = "${LDAP_PWD_FORBIDDEN_CHARS:-}";
# Don't reuse the same password as currently
\$pwd_no_reuse = ${LDAP_PWD_NO_REUSE:-true};
# Check that password is different than login
\$pwd_diff_login = ${LDAP_PWD_DIFF_LOGIN:-true};
# Check new passwords differs from old one - minimum characters count
\$pwd_diff_last_min_chars = ${LDAP_PWD_DIFF_LAST_MIN_CHARS:-0};
# Forbidden words which must not appear in the password
\$pwd_forbidden_words = array(${LDAP_PWD_FORBIDDEN_WORDS:-});
# Forbidden ldap fields
# Respective values of the user's entry must not appear in the password
# example: \$pwd_forbidden_ldap_fields = array('cn', 'givenName', 'sn', 'mail');
\$pwd_forbidden_ldap_fields = array(${LDAP_PWD_FORBIDDEN_LDAP_FIELDS:-});
# Complexity: number of different class of character required
\$pwd_complexity = ${LDAP_PWD_COMPLEXITY:-0};
# use pwnedpasswords api v2 to securely check if the password has been on a leak
\$use_pwnedpasswords = ${LDAP_PWDNED_PASSWORDS:-false};
# Show policy constraints message:
# always
# never
# onerror
\$pwd_show_policy = "${LDAP_PWD_SHOW_POLICY:-onerror}";
# Position of password policy constraints message:
# above - the form
# below - the form
\$pwd_show_policy_pos = "${LDAP_PWD_SHOW_POLICY_POS:-above}";

# disallow use of the only special character as defined in pwd_special_chars at the beginning and end
\$pwd_no_special_at_ends = false;

# Who changes the password?
# Also applicable for question/answer save
# user: the user itself
# manager: the above binddn
\$who_change_password = "user";

# Show extended error message returned by LDAP directory when password is refused
\$show_extended_error = "${LDAP_SHOW_EXTENDED_ERROR:-false}";

## Standard change
# Use standard change form?
\$use_change = true;

## SSH Key Change
# Allow changing of sshPublicKey?
\$change_sshkey = false;

# What attribute should be changed by the changesshkey action?
\$change_sshkey_attribute = "sshPublicKey";

# Who changes the sshPublicKey attribute?
# Also applicable for question/answer save
# user: the user itself
# manager: the above binddn
\$who_change_sshkey = "user";

# Notify users anytime their sshPublicKey is changed
## Requires mail configuration below
\$notify_on_sshkey_change = false;

## Questions/answers
# Use questions/answers?
\$use_questions = false;
# Allow to register more than one answer?
\$multiple_answers = false;
# Store many answers in a single string attribute
# (only used if \$multiple_answers = true)
\$multiple_answers_one_str = false;

# Answer attribute should be hidden to users!
\$answer_objectClass = "extensibleObject";
\$answer_attribute = "info";

# Crypt answers inside the directory
\$crypt_answers = true;

# Extra questions (built-in questions are in lang/\$lang.inc.php)
# Should the built-in questions be included?
\$questions_use_default = true;
#\$messages['questions']['ice'] = "What is your favorite ice cream flavor?";

# How many questions must be answered.
#  If = 1: legacy behavior
#  If > 1:
#    this many questions will be included in the page forms
#    this many questions must be set at a time
#    user must answer this many correctly to reset a password
#    \$multiple_answers must be true
#    at least this many possible questions must be available (there are only 2 questions built-in)
\$questions_count = 1;

# Should the user be able to select registered question(s) by entering only the login?
\$question_populate_enable = false;
## Token
# Use tokens?
# true (default)
# false
\$use_tokens = ${LDAP_USE_TOKENS:-false};
# Crypt tokens?
# true (default)
# false
\$crypt_tokens = true;
# Token lifetime in seconds
\$token_lifetime = "3600";

## Mail
# LDAP mail attribute
\$mail_attribute = "mail";
# Get mail address directly from LDAP (only first mail entry)
# and hide mail input field
# default = false
\$mail_address_use_ldap = ${LDAP_MAIL_USE_LDAP:-false};
# Who the email should come from
\$mail_from = "${LDAP_MAIL_FROM:-admin@example.com}";
\$mail_from_name = "${LDAP_MAIL_FROM_NAME:-Self Service Password}";
\$mail_signature = "";
# Notify users anytime their password is changed
\$notify_on_change = ${LDAP_MAIL_NOTIFY:-false};
# PHPMailer configuration (see https://github.com/PHPMailer/PHPMailer)
\$mail_sendmailpath = '/usr/sbin/sendmail';
\$mail_protocol = "${LDAP_MAIL_PROTOCOL:-smtp}";
\$mail_smtp_debug = "${LDAP_SMTP_DEBUG:-0}";
\$mail_debug_format = 'error_log';
\$mail_smtp_host = "${LDAP_SMTP_HOST:-localhost}";
\$mail_smtp_auth = ${LDAP_SMTP_AUTH:-false};
\$mail_smtp_user = "${LDAP_SMTP_USER:-}";
\$mail_smtp_pass = "${LDAP_SMTP_PASS:-}";
\$mail_smtp_port = ${LDAP_SMTP_PORT:-25};
\$mail_smtp_timeout = ${LDAP_SMTP_TIMEOUT:-30};
\$mail_smtp_keepalive = ${LDAP_SMTP_KEEPALIVE:-false};
\$mail_smtp_secure = "${LDAP_SMTP_SECURE:-tls}";
\$mail_smtp_autotls = ${LDAP_SMTP_AUTOTLS:-true};
\$mail_smtp_options = array();
\$mail_contenttype = 'text/plain';
\$mail_wordwrap = 0;
\$mail_charset = 'utf-8';
\$mail_priority = 3;

## SMS
# Use sms
\$use_sms = false;
# SMS method (mail, api)
\$sms_method = "mail";
\$sms_api_lib = "lib/smsapi.inc.php";
# GSM number attribute
\$sms_attribute = "mobile";
# Partially hide number
\$sms_partially_hide_number = true;
# Send SMS mail to address
\$smsmailto = "{sms_attribute}@service.provider.com";
# Subject when sending email to SMTP to SMS provider
\$smsmail_subject = "Provider code";
# Message
\$sms_message = "{smsresetmessage} {smstoken}";
# Remove non digit characters from GSM number
\$sms_sanitize_number = false;
# Truncate GSM number
\$sms_truncate_number = false;
\$sms_truncate_number_length = 10;
# SMS token length
\$sms_token_length = 6;
# Max attempts allowed for SMS token
\$max_attempts = 3;

# Encryption, decryption keyphrase, required if \$crypt_tokens = true
# Please change it to anything long, random and complicated, you do not have to remember it
# Changing it will also invalidate all previous tokens and SMS codes
\$keyphrase = "${LDAP_KEYPHRASE}";

# Reset URL (if behind a reverse proxy)
\$reset_url = \$_SERVER['HTTP_X_FORWARDED_PROTO'] . "://" . \$_SERVER['HTTP_X_FORWARDED_HOST'] . \$_SERVER['SCRIPT_NAME'];

# Display help messages
\$show_help = true;

# Default language
\$lang = "${LDAP_LANG:-en}";

# List of authorized languages. If empty, all language are allowed.
# If not empty and the user's browser language setting is not in that list, language from \$lang will be used.
\$allowed_lang = array();

# Display menu on top
\$show_menu = true;

# Logo
\$logo = "images/ltb-logo.png";

# Background image
\$background_image = "images/unsplash-space.jpeg";

\$custom_css = "";
\$display_footer = true;

# Where to log password resets - Make sure apache has write permission
# By default, they are logged in Apache log
#\$reset_request_log = "/var/log/self-service-password";

# Invalid characters in login
# Set at least "*()&|" to prevent LDAP injection
# If empty, only alphanumeric characters are accepted
\$login_forbidden_chars = "*()&|";

## Captcha
\$use_captcha = ${LDAP_USE_CAPTCHA:-false};

## Default action
# change
# sendtoken
# sendsms
\$default_action = "${LDAP_DEFAULT_ACTION:-change}";

## Rest API
\$use_restapi = ${LDAP_USE_RESTAPI:-false};

## Extra messages
# They can also be defined in lang/ files
#\$messages['passwordchangedextramessage'] = NULL;
#\$messages['changehelpextramessage'] = NULL;

## Pre Hook
# Launch a prehook script before changing password.
# Script should return with 0, to allow password change.
# Any other exit code would abort password modification
#\$prehook = "/usr/share/self-service-password/prehook.sh";
# Display prehook error
#\$display_prehook_error = true;
# Encode passwords sent to prehook script as base64. This will prevent alteration of the passwords if set to true.
# To read the actual password in the prehook script, use a base64_decode function/tool
#\$prehook_password_encodebase64 = false;
# Ignore prehook error. This will allow to change password even if prehook script fails.
#\$ignore_prehook_error = true;

## Post Hook
# Launch a posthook script after successful password change
#\$posthook = "/usr/share/self-service-password/posthook.sh";
# Display posthook error
#\$display_posthook_error = true;
# Encode passwords sent to posthook script as base64. This will prevent alteration of the passwords if set to true.
# To read the actual password in the posthook script, use a base64_decode function/tool
#\$posthook_password_encodebase64 = false;

# Force setlocale if your default PHP configuration is not correct
#setlocale(LC_CTYPE, "en_US.UTF-8");

# Hide some messages to not disclose sensitive information
# These messages will be replaced by badcredentials error
#\$obscure_failure_messages = array("mailnomatch");

# HTTP Header name that may hold a login to preset in forms
#\$header_name_preset_login="Auth-User";

# The name of an HTTP Header that may hold a reference to an extra config file to include.
#\$header_name_extra_config="SSP-Extra-Config";

# Cache directory
#\$smarty_compile_dir = "/var/cache/self-service-password/templates_c";
#\$smarty_cache_dir = "/var/cache/self-service-password/cache";

# Allow to override current settings with local configuration
if (file_exists (__DIR__ . '/config.inc.local.php')) {
    require __DIR__ . '/config.inc.local.php';
}

# Smarty
if (!defined("SMARTY")) {
    define("SMARTY", "/usr/share/php/smarty3/Smarty.class.php");
}

# Set preset login from HTTP header \$header_name_preset_login
\$presetLogin = "";
if (isset(\$header_name_preset_login)) {
    \$presetLoginKey = "HTTP_".strtoupper(str_replace('-','_',\$header_name_preset_login));
    if (array_key_exists(\$presetLoginKey, \$_SERVER)) {
        \$presetLogin = preg_replace("/[^a-zA-Z0-9-_@\.]+/", "", filter_var(\$_SERVER[\$presetLoginKey], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH));
    }
}

# Allow to override current settings with an extra configuration file, whose reference is passed in HTTP_HEADER \$header_name_extra_config
if (isset(\$header_name_extra_config)) {
    \$extraConfigKey = "HTTP_".strtoupper(str_replace('-','_',\$header_name_extra_config));
    if (array_key_exists(\$extraConfigKey, \$_SERVER)) {
        \$extraConfig = preg_replace("/[^a-zA-Z0-9-_]+/", "", filter_var(\$_SERVER[\$extraConfigKey], FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH));
        if (strlen(\$extraConfig) > 0 && file_exists (__DIR__ . "/config.inc.".\$extraConfig.".php")) {
            require  __DIR__ . "/config.inc.".\$extraConfig.".php";
        }
    }
}
?>
EOF
fi

if [ "${LDAP_SMTP_ALLOW_SELFSIGNED:-false}" == "true" ]; then
  sed -i "/\$mail_smtp_options = array();/c\$mail_smtp_options = array('ssl'=>array('verify_peer' => false,'verify_peer_name' => false,'allow_self_signed' => true));" /usr/share/"${LTB_PROJECT}"/conf/config.inc.php
fi
