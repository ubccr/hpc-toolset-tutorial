#-------------------------------------------------------------------------------
# Helper functions

proc selectMenuOption { option } {

	expect {
		-re "\nSelect an option .*: "
	}
	send $option\n
}

proc answerQuestion { question response } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
		-re "\n$question: \\\[.*\\\] "
	}
	send $response\n
}

proc answerQuestionAlt { question response } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
        -re "\n$question \\\[.*\\\] "
	}
	send $response\n
}

proc provideInput { prompt response } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
		"\n$prompt "
	}
	send $response\n
}

proc providePassword { prompt password } {
	provideInput $prompt $password
	provideInput "(confirm) $prompt" $password

}

proc enterToContinue { } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
		"\nPress ENTER to continue. "
	}
	send \n
}

proc confirmFileWrite { response } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
		-re "\nOverwrite config file .*\\\[.*\\\] "
	}
	send $response\n
}

proc confirmDropDb { response } {
	expect {
		timeout { send_user "\nFailed to get prompt\n"; exit 1 }
		-re "\nDrop and recreate database .*\\\[.*\\\] "
	}
	send $response\n
}
