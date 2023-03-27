namespace eval mpv {
	namespace export setInOut goTo pause play setVolume setMute isMuted

	variable mpvPath $setting::mpvPath
	variable duration
	variable pid
	variable fifo
	variable fifoId
	variable time
	variable mute false

	proc setInOut {filePath position} {
		variable mpvPath
		variable pid
		variable inReadChanId
		variable inWriteChanId
		variable time
		variable fifo
		variable fifoId
		set wid [expr [winfo id $viewer::video]]
		lassign [chan pipe] outReadChanId outWriteChanId
		set fifo "/tmp/mpvsocket"
		exec mkfifo $fifo
		#set pid [exec >&@$outWriteChanId $mpvPath --input-ipc-server=$fifo --no-config --no-osc --osd-level=0 --volume=0 --start=+$position --wid=$wid $filePath &]
		set pid [exec $mpvPath --input-ipc-server=$fifo --no-config --no-osc --osd-level=0 --volume=0 --start=+$position --wid=$wid $filePath &]
		#fileevent $outReadChanId readable [list mpv::readOutput $outReadChanId]
		set fifoId [open $fifo w+]
		set time 0
	}

	proc readOutput {pipe} {
		if {[eof $pipe]} {
			catch {close $pipe}
			return
		}
		gets $pipe line
	}

	proc extractTime {line} {
		puts [string range [string trimleft $line "\n "] 0 2]
		if {[string range $line 0 2] eq "AV:"} {
			set q [string first "/" $line 3]
			set result [string range $line 3 [expr $q - 1]]
		} else {
			set result ""
		}
		return $result
	}

	proc setVolume {vol} {
		if {[player::isPaused]} {
			variable time
			set t $time
		}
		#sendCommand "volume $vol 1"
		sendCommand [format "volume %d 1" $vol]
		if {[player::isPaused]} {
			player::setPaused 0
			player::pause
			goTo $t
		}
	}

	proc setMute {flag} {
		variable mute
		if {$flag ne $mute} {
			set mute $flag
			if {[player::isPaused]} {
				variable time
				set t $time
			}
			if {$flag} {
				sendCommand "mute 1"
			} else {
				sendCommand "mute 0"
			}
			if {[player::isPaused]} {
				player::setPaused 0
				player::pause
				goTo $t
			}
		}
	}

	proc isMuted {} {
		variable mute
		return $mute
	}

	proc goTo {millis} {
		set t [expr $millis * 0.001]
		#sendCommand "pausing seek $t 2"
		sendCommand [format "pausing seek %f 2" $t]
	}

	proc pause {} {
		#sendCommand "set pause yes"
		sendCommand "{ \"command\": \[\"set_property\", \"pause\", true\] }"
	}

	proc play {} {
		sendCommand "pause"
	}

	proc closeSession {} {
		variable pid
		variable fifo
		variable fifoId
		if {[info exists fifo]} {
			sendCommand "quit"
			close $fifoId
			exec unlink $fifo
			unset fifo
		}
		if {[info exists pid]} {
			exec kill -9 $pid
			unset pid
		}
	}

	proc sendCommand {command} {
		variable fifoId
		puts $fifoId $command
		flush $fifoId
		gets $fifoId result
		puts $result
		return $result
	}
}
