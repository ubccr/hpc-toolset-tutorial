<?php
$config = array(
  'xdmod-sp' => array(
    'saml:SP',
    'host'=> 'localhost:4443',
    'entityID' => 'https://localhost:4443/simplesaml/module.php/saml/sp/metadata.php/xdmod-sp',
    'privatekey'  => 'xdmod-sp.key',
    'idp' => 'xdmod-hosted-idp-ldap',
    'signature.algorithm' => 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256',
    'authproc' => array(
      40 => array(
        'class' => 'core:AttributeMap',
        /*
         *  These will need to map to the fields you have in your ldap
         */
        'mail' => 'email_address',
        'givenName' => 'first_name',
        'sn' => 'last_name',
        'department' => 'field_of_science',
        'uid' => 'username'
      )
    )
  ),
  'ldap' => array(
    'ldap:LDAP',
    /*
     * testing username and pass:
     * Username: tesla
     * Password: password
     */

    /* The hostname of the LDAP server. */
    'hostname' => 'ldap',

    /* Whether SSL/TLS should be used when contacting the LDAP server. */
    'enable_tls' => TRUE,

    /*
    * Which attributes should be retrieved from the LDAP server.
    * This can be an array of attribute names, or NULL, in which case
    * all attributes are fetched.
    */
    'attributes' => NULL,

    /*
    * The pattern which should be used to create the user's DN given the username.
    * %username% in this pattern will be replaced with the user's username.
    *
    * This option is not used if the search.enable option is set to TRUE.
    */
    'dnpattern' => 'uid=%username%,dc=example,dc=org',

    /*
    * As an alternative to specifying a pattern for the users DN, it is possible to
    * search for the username in a set of attributes. This is enabled by this option.
    */
    'search.enable' => TRUE,

    /*
    * The DN which will be used as a base for the search.
    * This can be a single string, in which case only that DN is searched, or an
    * array of strings, in which case they will be searched in the order given.
    */
    'search.base' => 'dc=example,dc=org',

    /*
    * The attribute(s) the username should match against.
    *
    * This is an array with one or more attribute names. Any of the attributes in
    * the array may match the value the username.
    */
    'search.attributes' => array('uid', 'mail'),

    /*
    * The username & password where SimpleSAMLphp should bind to before searching. If
    * this is left NULL, no bind will be performed before searching.
    */
    'search.username' => 'cn=admin,dc=example,dc=org',
    'search.password' => 'admin'
  ),
  'admin' => array(
    // The default is to use core:AdminPassword, but it can be replaced with
    // any authentication source.
    'core:AdminPassword',
  ),
);

