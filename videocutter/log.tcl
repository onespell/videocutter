namespace eval log {
	namespace export init close info error

	variable logger [thread::create -joinable {

		proc openFile {filePath} {
			global file
			set file [open $filePath a]
		}

		proc closeFile {} {
			global file
			close $file
		}

		proc add {msg} {
			global file
			puts $file $msg
			flush $file
			thread::wait
		}

		thread::wait
		closeFile
	}]

	proc init {} {
		variable logger
		set cmd "openFile $setting::logPath"
		thread::send $logger $cmd
	}

	proc close {} {
		variable logger
		thread::release $logger
		thread::join $logger
	}

	proc info {msg} {
		variable logger
		set ln "[format "%s INFO - %s" [clock format [clock seconds] -format "%Y-%m-%d %T"] $msg]"
		set cmd "add [list $ln]"
		thread::send -async $logger $cmd
	}

	proc error {msg} {
		variable logger
		set ln "[format "%s ERROR - %s" [clock format [clock seconds] -format "%Y-%m-%d %T"] $msg]"
		set cmd "add [list $ln]"
		thread::send -async $logger $cmd
	}
}
