#!/usr/bin/env expect
# Expect script that run s xdmod-setup to configure a freshly installed
# XDMoD instance. This script will fail if run against an already installed
# XDMoD.

#-------------------------------------------------------------------------------
# Configuration settings for the XDMoD resources

#-------------------------------------------------------------------------------

# Load helper functions from helper-functions.tcl
source [file join [file dirname [info script]] helper-functions.tcl]

#-------------------------------------------------------------------------------
# main body - note there are some hardcoded addresses, usernames and passwords here
# they should typically not be changed as they need to match up with the
# settings in the docker container

set timeout 240
spawn "xdmod-setup"

selectMenuOption 9

selectMenuOption d
answerQuestionAlt {DB Admin Username:} root
providePassword {DB Admin Password:} {}
confirmDropDb yes
confirmDropDb yes
provideInput {MongoDB uri*} {mongodb://xdmod:xsZ0LpZstneBpijLy7@mongodb:27017/supremm?authSource=admin}
provideInput {database name*} {supremm}
confirmFileWrite yes
enterToContinue
set timeout 200
provideInput {Do you want to see the output*} {no}
set timeout 10

selectMenuOption r


# Enter config settings for each resource
selectMenuOption 1
answerQuestionAlt {Enabled \(yes, no\)} {yes}
answerQuestionAlt {Dataset mapping} {pcp}
provideInput {GPFS mount point (leave empty if no GPFS)} {}

selectMenuOption s
confirmFileWrite yes
enterToContinue
selectMenuOption q

selectMenuOption q

lassign [wait] pid spawnid os_error_flag value
exit $value
