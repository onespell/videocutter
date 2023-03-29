namespace eval mpv {
	namespace export setInOut goTo pause play setVolume setMute isMuted

	variable mpvPath $setting::mpvPath
	variable duration
	variable pid
	variable so
	variable time
	variable mute false

	proc setInOut {filePath position} {
		variable mpvPath
		variable pid
		variable inReadChanId
		variable inWriteChanId
		variable time
		variable so
		set wid [expr [winfo id $viewer::video]]
		set so "/tmp/mpv_socket"
		set pid [exec $mpvPath --input-ipc-server=$so --no-osc --osd-level=0 --pause --volume=0 --start=+$position --wid=$wid $filePath &]
		set time 0
		util::sleep 100
	}

	proc setVolume {vol} {
		if {[player::isPaused]} {
			variable time
			set t $time
		}
		sendCommand [format "{{\"command\":\[\"set_property\",\"volume\",%d\]}}" $vol]
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
				sendCommand "{{\"command\":\[\"set_property\",\"mute\",true\]}}"
			} else {
				sendCommand "{{\"command\":\[\"set_property\",\"mute\",false\]}}"
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
		#set t [util::toTimeCode $millis]
		#sendCommand [format "{\"command\":\[\"seek\",\"%s\"\]}" $t]
		#set t [expr $millis * 0.001]
		#sendCommand [format "{\"command\":\[\"set_property\",\"time-pos\",\"%f\"\]}" $t]
		set t [util::toTimeCode $millis]
		sendCommand [format "seek %s" $t]
	}

	proc pause {} {
		sendCommand "{{\"command\":\[\"set_property\",\"pause\",true\]}}"
	}

	proc play {} {
		sendCommand "{{\"command\":\[\"set_property\",\"pause\",false\]}}"
	}

	proc closeSession {} {
		variable pid
		variable so
		if {[info exists so]} {
			#sendCommand "{{\"command\":\[\"quit\"\]}}"
			sendCommand "quit"
			exec unlink $so
			unset so
		}
		if {[info exists pid]} {
			exec kill -9 $pid
			unset pid
		}
	}

	proc sendCommand {command} {
		puts $command
		variable so
		#set io [open "|socat - $so" r+]
		set io [open "| echo $command | socat - $so" r]
		foreach line [split [read $io] \n] {
			puts $line
		}
	}
}
