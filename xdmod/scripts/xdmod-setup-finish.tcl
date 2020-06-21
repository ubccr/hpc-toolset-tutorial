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

selectMenuOption 5
provideInput {Username:} admin
providePassword {Password:} admin
provideInput {First name:} Admin
provideInput {Last name:} User
provideInput {Email address:} admin@localhost
enterToContinue

selectMenuOption 6
answerQuestion {Top Level Name} {Decanal Unit}
provideInput {Top Level Description:} {Decanal Unit}
answerQuestion {Middle Level Name} {Department}
provideInput {Middle Level Description:} {Department}
answerQuestion {Bottom Level Name} {PI Group}
provideInput {Bottom Level Description:} {PI Group}
confirmFileWrite yes
enterToContinue

selectMenuOption 7
provideInput {Export Directory*} {}
provideInput {Export File Retention Duration*} 31
confirmFileWrite yes
enterToContinue

selectMenuOption q

lassign [wait] pid spawnid os_error_flag value
exit $value
