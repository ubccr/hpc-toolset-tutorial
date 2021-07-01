#!/usr/bin/env expect
# Expect script that run s xdmod-setup to configure a freshly installed
# XDMoD instance. This script will fail if run against an already installed
# XDMoD.

#-------------------------------------------------------------------------------
# Configuration settings for the XDMoD OnDemand Module

#-------------------------------------------------------------------------------

# Load helper functions from helper-functions.tcl
source [file join [file dirname [info script]] helper-functions.tcl]

#-------------------------------------------------------------------------------
# main body - note there are some hardcoded addresses, usernames and passwords here
# they should typically not be changed as they need to match up with the
# settings in the docker container

set timeout 240
spawn "xdmod-setup"

selectMenuOption 10

selectMenuOption d
answerQuestionAlt {DB Admin Username:} root
providePassword {DB Admin Password:} {}
confirmDropDb yes
provideInput {Do you want to see the output*} {no}

selectMenuOption q

#-------------------------------------------------------------------------------
# Adding the OnDemand resource
#-------------------------------------------------------------------------------
selectMenuOption 4
selectMenuOption 1
provideInput {Resource Name:} ondemand
provideInput {Formal Name:} OnDemand
provideInput {Resource Type*} gateway
provideInput {How many nodes does this resource have?} 1
provideInput {How many total processors (cpu cores) does this resource have?} 1

# Save the newly added resource & confirm overwriting the configuration files.
selectMenuOption s
confirmFileWrite yes
enterToContinue
confirmFileWrite yes
enterToContinue


selectMenuOption q
selectMenuOption q

lassign [wait] pid spawnid os_error_flag value
exit $value
