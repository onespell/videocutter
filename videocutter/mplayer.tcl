namespace eval mplayer {
	namespace export setInOut goTo pause play setVolume setMute isMuted

	variable mplayerPath $setting::mplayerPath
	variable duration
	variable pid
	variable inReadChanId
	variable inWriteChanId
	variable time
	variable mute false

	proc setInOut {filePath position} {
		variable mplayerPath
		variable pid
		variable inReadChanId
		variable inWriteChanId
		variable time
		set wid [expr [winfo id $viewer::video]]
		lassign [chan pipe] outReadChanId outWriteChanId
		lassign [chan pipe] inReadChanId inWriteChanId
		fconfigure $inWriteChanId -buffersize 0
		set pid [exec >&@$outWriteChanId <@$inReadChanId $mplayerPath -slave -identify -softvol -osdlevel 0 -volume 0 -ss $position -wid $wid $filePath &]
		fileevent $outReadChanId readable [list mplayer::readOutput $outReadChanId]
		set time 0
	}

	proc readOutput {pipe} {
		if {[eof $pipe]} {
			catch {close $pipe}
			return
		}
		gets $pipe line
		if {[player::isPaused]} {
			return
		}
		set t [extractTime $line]
		if {$t ne ""} {
			variable time
			set time [util::toMillis $t]
			mediabar::setTime $time
			shotBox::setTime $time
			clipBox::setTime $time
		}
	}

	proc extractTime {line} {
		if {[string range $line 0 1] eq "A:"} {
			set p [expr [string first " V:" $line] + 3]
			set q [string first " A-V:" $line $p]
			set result [string range $line $p [expr $q - 1]]
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
		sendCommand "pause"
	}

	proc play {} {
		sendCommand "pause"
	}

	proc closeSession {} {
		variable pid
		variable inReadChanId
		variable inWriteChanId
		if {[info exists inWriteChanId]} {
			sendCommand "quit"
			close $inWriteChanId
			close $inReadChanId
			unset inWriteChanId inReadChanId
		}
		if {[info exists pid]} {
			exec kill -9 $pid
			unset pid
		}
	}

	proc sendCommand {command} {
		variable inWriteChanId
		puts $inWriteChanId $command
		#flush $inWriteChanId
	}
}
