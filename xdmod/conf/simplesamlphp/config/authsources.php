<?php
$config = array(
  'xdmod-sp' => array(
    'saml:SP',
    'host'=> 'localhost:4443',
    'entityID' => 'https://localhost:4443/simplesaml/module.php/saml/sp/metadata.php/xdmod-sp',
    'idp' => 'xdmod-hosted-idp-dex',
    'authproc' => array(
      40 => array(
        'class' => 'core:AttributeMap',
        /*
         *  These will need to map to the fields from DEX to what Open XDMoD uses
         */
        'email' => 'email_address',
        'preferred_username' => 'username'
      ),
      // Ensures that the 'username' property has one or more non-whitespace characters
      60 => array(
        'class' => 'authorize:Authorize',
        'username' => array(
          '/\S+/'
        ),
      )
    )
  ),
  'dex'=> array(
    'authoidcoauth2:OIDCOAuth2',
    'auth_endpoint' => 'https://localhost:5554',
    'api_endpoint' => 'https://ondemand:5554',
    'key' => 'localhost',
    'secret' => '334389048b872a533002b34d73f8c29fd09efc50',
    'scope' => 'openid email profile',
    'response_type' => 'code',
    'redirect_uri' => 'https://localhost:4443/simplesaml/module.php/authoidcoauth2/linkback.php'
  ),
  'admin' => array(
    // The default is to use core:AdminPassword, but it can be replaced with
    // any authentication source.
    'core:AdminPassword',
  ),
);
