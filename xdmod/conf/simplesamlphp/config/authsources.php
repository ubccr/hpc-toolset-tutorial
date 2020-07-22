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
            ),
            // Use name if it has a space in it to be the first and last name otherwise use username 
            // assuming <first initial><last name> as the format
            70 => array(
                'class' => 'core:PHP',
                'code' => '
                    if (!empty($attributes["name"]) && strpos($attributes["name"][0], " ") !== false) {
                        $firstLast = explode(" ", $attributes["name"][0]);
                        $attributes["first_name"][0] = $firstLast[0];
                        $attributes["last_name"][0] = $firstLast[1];
                    }
                    else {
                        $attributes["first_name"][0] = strtoupper($attributes["username"][0][0]);
                        $attributes["last_name"][0] = substr($attributes["username"][0], 1);
                        $attributes["last_name"][0][0] = strtoupper($attributes["last_name"][0][0]);
                    }
                ',
            ),
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
        'redirect_uri' => 'https://localhost:4443/simplesaml/module.php/authoidcoauth2/linkback.php',
        'verify_ssl' => 0
    ),
    'admin' => array(
        // The default is to use core:AdminPassword, but it can be replaced with
        // any authentication source.
        'core:AdminPassword',
    ),
);
