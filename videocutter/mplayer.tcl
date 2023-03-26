namespace eval mplayer {
	namespace export init loadFile goTo pause play setVolume setMute

	variable mplayerPath
	variable duration
	variable pid
	variable inReadChanId
	variable inWriteChanId
	variable mute false
	variable paused false
	variable time

	proc init {path} {
		variable mplayerPath
		set mplayerPath $path
	}

	proc loadFile {aFilePath position} {
		closeSession
		toolBox::setEnabled 0
		set splash [wid::showWaitSplash [mc loading]]
		variable mplayerPath
		variable duration
		variable pid
		variable inReadChanId
		variable inWriteChanId
		variable paused
		variable mute
		variable time
		set filePath [list $aFilePath]
		session::setFilePath $filePath
		set sizes [analysis::getFrameSizes $filePath]
		set size [lindex $sizes 0]
		set width [size::getWidth $size]
		set height [size::getHeight $size]
		set keyFrames [analysis::getKeyFrames $filePath]
		player::setSize $width $height
		set duration [analysis::getDuration $filePath]
		set format [analysis::getFormat $filePath]
		lassign [analysis::getMediaStreams $filePath] videoStreams audioStreams
		clipBox::reset $format $duration $sizes [lindex $videoStreams 0] $audioStreams
		set wid [expr [winfo id $player::video ]]
		lassign [chan pipe] outReadChanId outWriteChanId
		lassign [chan pipe] inReadChanId inWriteChanId
		fconfigure $inWriteChanId -buffersize 0
		set pid [exec >&@$outWriteChanId <@$inReadChanId $mplayerPath -slave -identify -softvol -osdlevel 0 -volume 0 -ss $position -wid $wid $aFilePath &]
		fileevent $outReadChanId readable [list mplayer::readOutput $outReadChanId]
		pause
		set time 0
		if {$setting::muteOnStart} {
			setMute true
		}
		if {$session::volume > 0} {
			setVolume $session::volume
		}
		goTo 0
		mediabar::reset $duration $paused 0 $session::volume $mute $keyFrames
		jobBox::reset
		toolBox::setEnabled 1
		log::info "open $filePath"
		wid::destroySplash $splash
	}

	proc readOutput {pipe} {
		if {[eof $pipe]} {
			catch {close $pipe}
			return
		}
		gets $pipe line
		variable paused
		if {$paused eq true} {
			return
		}
		set t [util::extractTime $line]
		if {$t ne ""} {
			variable time
			set time [util::toMillis $t]
			mediabar::setTime $time
			shotBox::setTime $time
			clipBox::setTime $time
		}
	}

	proc setVolume {vol} {
		if {$vol ne $session::volume} {
			session::setVolume $vol
			variable paused
			if {$paused} {
				variable time
				set t $time
			}
			#sendCommand "volume $vol 1"
			sendCommand [format "volume %d 1" $vol]
			if {$paused} {
				set paused false
				pause
				goTo $t
			}
		}
	}

	proc setMute {flag} {
		variable mute
		if {$flag ne $mute} {
			set mute $flag
			variable paused
			if {$paused} {
				variable time
				set t $time
			}
			if {$flag} {
				sendCommand "mute 1"
			} else {
				sendCommand "mute 0"
			}
			if {$paused} {
				set paused false
				pause
				goTo $t
			}
		}
	}

	proc goTo {millis} {
		set t [expr $millis * 0.001]
		#sendCommand "pausing seek $t 2"
		sendCommand [format "pausing seek %f 2" $t]
		shotBox::setTime $millis
		clipBox::setTime $millis
	}

	proc pause {} {
		variable paused
		if {$paused ne true} {
			set paused true
			sendCommand "pause"
		}
	}

	proc play {} {
		variable paused
		if {$paused} {
			set paused false
			sendCommand "pause"
		}
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
