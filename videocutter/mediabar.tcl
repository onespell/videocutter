namespace eval mediabar {
	namespace export init frame setDuration setTime reset goTo

	variable frame
	variable pauseBtn
	variable pauseBtnState; # 0 - playing, 1 - on pause
	variable timeScl
	variable rewindBtn
	variable forwardBtn
	variable volumeScl
	variable muteBtn
	variable muteBtnState; # 0 - unmuted, 1 - muted
	variable playImg
	variable pauseImg
	variable rewindImg
	variable forwardImg
	variable muteImg
	variable unmuteImg
	variable time
	variable volume
	variable keyFrames
	variable playImg
	variable pauseImg
	variable rewindImg
	variable forwardImg
	variable muteImg
	variable unmuteImg

	proc init {workdir parent} {
		variable frame
		set frame [frame $parent.mediaControls -borderwidth 10]

		image create photo mediabar::playImg -file $workdir/svg/play.svg -format {svg -scaletoheight 24}
		image create photo mediabar::pauseImg -file $workdir/svg/pause.svg -format {svg -scaletoheight 24}
		image create photo mediabar::rewindImg -file $workdir/svg/rewind.svg -format {svg -scaletoheight 24}
		image create photo mediabar::forwardImg -file $workdir/svg/forward.svg -format {svg -scaletoheight 24}
		image create photo mediabar::muteImg -file $workdir/svg/mute.svg -format {svg -scaletoheight 24}
		image create photo mediabar::unmuteImg -file $workdir/svg/unmute.svg -format {svg -scaletoheight 24}
	
		variable rewindBtn
		set rewindBtn [button $frame.rewind -image mediabar::rewindImg -command mediabar::rewind -width 30 -height 30]
		help $rewindBtn balloon [mc prevKeyFrame]

		variable forwardBtn
		set forwardBtn [button $frame.forward -image mediabar::forwardImg -command mediabar::forward -width 30 -height 30]
		help $forwardBtn balloon [mc nextKeyFrame]

		variable pauseBtn
		variable pauseBtnState
		set pauseBtn [button $frame.pause -width 30 -height 30]
		set pauseBtnState 0
		switchPauseBtnMode

		variable timeScl
		set timeScl [scale $frame.time -orient horizontal -showvalue false -variable mediabar::time -command mediabar::goTo]

		variable volumeScl
		set volumeScl [scale $frame.volume -orient horizontal -length 50 -variable mediabar::volume -command mediabar::setVolume]
		help $volumeScl balloon [mc volume]

		variable muteBtn
		variable muteBtnState
		set muteBtn [button $frame.mute -width 30 -height 30]
		set muteBtnState 0
		switchMuteBtnMode

		bind . "<Key-Down>" mediabar::rewind
		bind . "<Key-Up>" mediabar::forward

		pack $pauseBtn -side left
		pack $muteBtn -side right
		pack $volumeScl -side right
		pack $forwardBtn -side right
		pack $rewindBtn -side right
		pack $timeScl -side left -fill x -expand true
	}

	proc switchPauseBtnMode {} {
		variable pauseBtn
		variable pauseBtnState
		variable rewindBtn
		variable forwardBtn
		switch -exact -- $pauseBtnState {
			0 {
				$pauseBtn config -image mediabar::pauseImg -command {set mediabar::pauseBtnState 1; mediabar::switchPauseBtnMode; mplayer::pause};
				help $pauseBtn balloon [mc pause]
				$rewindBtn config -state disabled
				$forwardBtn config -state disabled
			}
			1 {
				$pauseBtn config -image mediabar::playImg -command {set mediabar::pauseBtnState 0; mediabar::switchPauseBtnMode; mplayer::play};
				help $pauseBtn balloon [mc play]
				$rewindBtn config -state normal
				$forwardBtn config -state normal
			}
		}
	}

	proc switchMuteBtnMode {} {
		variable muteBtn
		variable muteBtnState
		switch -exact -- $muteBtnState {
			0 {
				$muteBtn config -image mediabar::unmuteImg -command {set mediabar::muteBtnState 1; mediabar::switchMuteBtnMode; mplayer::setMute true};
				help $muteBtn balloon [mc mute]
			}
			1 {
				$muteBtn config -image mediabar::muteImg -command {set mediabar::muteBtnState 0; mediabar::switchMuteBtnMode; mplayer::setMute false};
				help $muteBtn balloon [mc unmute]
			}
		}
	}

	proc setDuration {value} {
		variable timeScl
		$timeScl config -from 0 -to $value
	}

	proc setTime {value} {
		variable pauseBtnState
		if {$pauseBtnState == 0} {
			variable time
			set time $value
		}
	}

	proc rewind {} {
		variable time
		variable keyFrames
		set t $time
		lassign [getInterval $t] left right
		if {$left < 0} {
			return
		}
		if {[lindex $keyFrames $left] < $t} {
			set i $left
		} elseif {$left > 0} {
			set i [expr $left - 1]
		} else {
			return
		}
		goTo [lindex $keyFrames $i]
	}

	proc forward {} {
		variable time
		variable keyFrames
		set t $time
		lassign [getInterval $t] left right
		if {$right >= 0} {
			set next [lindex $keyFrames $right]
			goTo $next
		}
	}

	proc getInterval {t} {
		variable keyFrames
		set right [expr [llength $keyFrames] - 1]
		if {$right < 0} {
			return [list -1 -1]
		}
		set rightValue [lindex $keyFrames $right]
		if {$t >= $rightValue} {
			return [list $right -1]
		}
		if {$right == 0} {
			return [list -1 $right]
		}
		set left 0
		set leftValue [lindex $keyFrames $left]
		if {$leftValue > $t} {
			return [list -1 $left]
		}
		if {$leftValue == $t} {
			return [list $left [expr $left + 1]]
		}
		while {[expr $right - $left] > 1} {
			#set middle [expr int(floor(($right + $left) / 2))]
			set middle [expr int(($right + $left) / 2)]
			set middleValue [lindex $keyFrames $middle]
			if {$middleValue < $t} {
				set left $middle
				set leftValue $middleValue
			} elseif {$middleValue > $t} {
				set right $middle
				set rightValue $middleValue
			} else {
				set left $middle
				set right [expr $left + 1]
			}
		}
		return [list $left $right]
	}

	proc goTo {millis} {
		variable pauseBtnState
		if {$pauseBtnState == 1} {
			mplayer::goTo $millis
			variable time
			set time $millis
		}
	}

	proc setVolume {vol} {
		mplayer::setVolume $vol
	}

	proc reset {paused millis vol mute frames} {
		variable pauseBtnState
		if {$paused} {
			set pauseBtnState 1
		} else {
			set pauseBtnState 0
		}
		switchPauseBtnMode
		variable time
		set time $millis
		variable volume
		set volume $vol
		variable muteBtnState
		if {$mute} {
			set muteBtnState 1
		} else {
			set muteBtnState 0
		}
		switchMuteBtnMode
		variable keyFrames
		set keyFrames $frames
	}
}
