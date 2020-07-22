#!/usr/bin/env expect
# Expect script that run s xdmod-setup to configure a freshly installed
# XDMoD instance. This script will fail if run against an already installed
# XDMoD.

# Load helper functions from helper-functions.tcl
source [file join [file dirname [info script]] helper-functions.tcl]

#-------------------------------------------------------------------------------
# main body - note there are some hardcoded addresses, usernames and passwords here
# they should typically not be changed as they need to match up with the
# settings in the docker container

set timeout 240
spawn "xdmod-setup"

selectMenuOption 1
answerQuestion {Site Address} https://localhost:4443/
provideInput {Email Address:} ccr-xdmod-help@buffalo.edu
answerQuestion {Java Path} /usr/bin/java
answerQuestion {Javac Path} /usr/bin/javac
provideInput {PhantomJS Path:} /usr/local/bin/phantomjs
provideInput {Center Logo Path:} /srv/xdmod/small-logo.png
provideInput {Center Logo Width:} 354
provideInput {Enable Dashboard Tab*} {on}
confirmFileWrite yes
enterToContinue

selectMenuOption 2
answerQuestion {DB Hostname or IP} mysql
answerQuestion {DB Port} 3306
answerQuestion {DB Username} xdmodapp
providePassword {DB Password:} ofbatgorWep0
answerQuestion {DB Admin Username} root
providePassword {DB Admin Password:} {}
confirmDropDb yes
confirmDropDb yes
confirmDropDb yes
confirmDropDb yes
confirmDropDb yes
confirmDropDb yes
confirmDropDb yes
confirmFileWrite yes
enterToContinue

selectMenuOption 3
provideInput {Organization Name:} Tutorial
provideInput {Organization Abbreviation:} hpcts
confirmFileWrite yes
enterToContinue

selectMenuOption q

lassign [wait] pid spawnid os_error_flag value
exit $value
