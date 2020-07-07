<?php
/**
 * SAML 2.0 remote IdP metadata for SimpleSAMLphp.
 *
 * Remember to remove the IdPs you don't use from this file.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-idp-remote
 *
 * THIS IS A DUMMY PLACEHOLDER IT WILL BE REPLACED
 */

$metadata['xdmod-hosted-idp-ldap'] = array (
  'metadata-set' => 'saml20-idp-remote',
  'entityid' => 'xdmod-hosted-idp-ldap',
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
