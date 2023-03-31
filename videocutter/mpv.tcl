namespace eval sysplayer {
	namespace export setInOut goTo pause play setVolume setMute isMuted

	variable mpvPath $setting::mpvPath
	variable duration
	variable pid
	variable so
	variable time
	variable mute false
	variable period 100
	variable shutdown 0

	proc setInOut {filePath position} {
		variable mpvPath
		variable pid
		variable inReadChanId
		variable inWriteChanId
		variable time
		variable mute
		variable so
		variable shutdown
		set shutdown 0
		set wid [expr [winfo id $viewer::video]]
		set so "/tmp/mpv_socket"
		set pid [exec >&/dev/null $mpvPath --input-ipc-server=$so --no-osc --osd-level=0 --no-config --no-terminal --no-input-builtin-bindings --no-input-default-bindings --pause --volume=0 --start=+$position --wid=$wid $filePath &]
		set time 0
		set mute false
		player::setPaused 1
		util::sleep 100
		getPosition
		if {$setting::muteOnStart} {
			player::setMute true
		}
		if {$session::volume > 0} {
			player::setVolumeForcibly $session::volume
		}
	}

	proc getPosition {} {
		variable shutdown
		if {$shutdown} {
			return
		}
		variable period
		if {[player::isPaused]} {
			after $period sysplayer::getPosition
			return
		}
		set id [clock clicks -milliseconds]
		set cmd "{{\"command\":\[\"get_property\",\"playback-time\"\],\"request_id\":"
		append cmd $id
		append cmd "}}"
		set line [sendCommandAndRead $cmd]
		if {[catch {set d [::json::json2dict $line]}]} {
			after $period sysplayer::getPosition
			return
		}
		if {[catch {set reqid [dict get $d "request_id"]}]} {
			after $period sysplayer::getPosition
			return
		}
		if {$reqid ne $id} {
			after $period sysplayer::getPosition
			return
		}
		if {[catch {set t [dict get $d "data"]}]} {
			after $period sysplayer::getPosition
			return
		}
		variable time
		set time [util::toMillis $t]
		mediabar::setTime $time
		shotBox::setTime $time
		clipBox::setTime $time
		after $period sysplayer::getPosition
	}

	proc extractTime {line} {
		set p [expr [string first "\"data\":" $line] + 7]
		set q [expr [string first "," $line $p] - 1]
		set seconds [string trim [string range $line $p $q]]
		set millis [util::toMillis $seconds]
		return $millis
	}

	proc setVolume {vol} {
		sendCommand [format "{{\"command\":\[\"set_property\",\"volume\",%d\]}}" $vol]
	}

	proc setMute {flag} {
		variable mute
		if {$flag ne $mute} {
			set mute $flag
			if {$flag} {
				sendCommand "{{\"command\":\[\"set_property\",\"mute\",true\]}}"
			} else {
				sendCommand "{{\"command\":\[\"set_property\",\"mute\",false\]}}"
			}
		}
	}

	proc isMuted {} {
		variable mute
		return $mute
	}

	proc goTo {millis} {
		set t [util::toTimeCode $millis]
		sendCommand [format "seek %s absolute" $t]
	}

	proc pause {} {
		#sendCommand "{{\"command\":\[\"set_property\",\"pause\",true\]}}"
		sendCommand "cycle pause"
	}

	proc play {} {
		#sendCommand "{{\"command\":\[\"set_property\",\"pause\",false\]}}"
		sendCommand "cycle pause"
	}

	proc closeSession {} {
		variable pid
		variable so
		variable shutdown
		set shutdown 1
		if {[info exists so]} {
			sendCommand "quit"
			util::sleep 100
			exec unlink $so
			unset so
		}
		if {[info exists pid]} {
			if {[catch {exec kill -9 $pid} result]} {}
			unset pid
		}
	}

	proc sendCommandAndRead {command} {
		variable so
		set io [open "| echo $command | socat - $so" r]
		foreach line [split [read $io] \n] {
			catch {close $io}
			return $line
		}
	}

	proc sendCommand {command} {
		variable so
		set io [open "| echo $command | socat - $so" r]
		catch {close $io}
	}
}
