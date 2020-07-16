#!/bin/bash

mkdir -p /etc/xdmod/simplesamlphp/{config,metadata,cert}

certString=`cat /etc/pki/tls/certs/localhost.crt | head -n-1 | tail -n+2 | tr -d '\n'`

cat << EOF > /etc/xdmod/simplesamlphp/metadata/saml20-idp-remote.php
<?php
/**
 * SAML 2.0 remote IdP metadata for SimpleSAMLphp.
 *
 * Remember to remove the IdPs you don't use from this file.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-idp-remote
 */

\$metadata['xdmod-hosted-idp-dex'] = array (
  'metadata-set' => 'saml20-idp-remote',
  'entityid' => 'xdmod-hosted-idp-dex',
  'SingleSignOnService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://localhost:4443/simplesaml/saml2/idp/SSOService.php',
    ),
  ),
  'SingleLogoutService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://localhost:4443/simplesaml/saml2/idp/SingleLogoutService.php',
    ),
  ),
  'certData' => '$certString',
  'NameIDFormat' => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
);
EOF
