namespace eval mediabar {
	namespace export init frame setTime reset goTo setEnabled

	variable frame
	variable pauseBtn
	variable pauseBtnState; # 0 - playing, 1 - on pause
	variable timeScl
	variable rewindBtn
	variable refineLeftBtn
	variable refineRightBtn
	variable forwardBtn
	variable volumeScl
	variable muteBtn
	variable muteBtnState; # 0 - unmuted, 1 - muted
	variable playImg
	variable pauseImg
	variable rewindImg
	variable refineLeftImg
	variable refineRightImg
	variable forwardImg
	variable muteImg
	variable unmuteImg
	variable time
	variable volume
	variable keyFrames
	variable refine ""
	variable duration 0
	variable updatingTimeScale 0
	variable mediaEnabled 0

	proc init {workdir parent} {
		variable frame
		set frame [frame $parent.mediaControls -borderwidth 10]

		image create photo mediabar::playImg -file $workdir/svg/play.svg -format {svg -scaletoheight 24}
		image create photo mediabar::pauseImg -file $workdir/svg/pause.svg -format {svg -scaletoheight 24}
		image create photo mediabar::rewindImg -file $workdir/svg/rewind.svg -format {svg -scaletoheight 24}
		image create photo mediabar::refineLeftImg -file $workdir/svg/refineLeft.svg -format {svg -scaletoheight 24}
		image create photo mediabar::refineRightImg -file $workdir/svg/refineRight.svg -format {svg -scaletoheight 24}
		image create photo mediabar::forwardImg -file $workdir/svg/forward.svg -format {svg -scaletoheight 24}
		image create photo mediabar::muteImg -file $workdir/svg/mute.svg -format {svg -scaletoheight 24}
		image create photo mediabar::unmuteImg -file $workdir/svg/unmute.svg -format {svg -scaletoheight 24}

		variable rewindBtn
		set rewindBtn [button $frame.rewind -image mediabar::rewindImg -command mediabar::rewind -width 30 -height 30]
		help $rewindBtn balloon [mc prevKeyFrame]

		variable refineLeftBtn
		set refineLeftBtn [button $frame.refineLeft -image mediabar::refineLeftImg -command mediabar::refineLeft -width 30 -height 30]
		help $refineLeftBtn balloon [mc refineLeft]

		variable refineRightBtn
		set refineRightBtn [button $frame.refineRight -image mediabar::refineRightImg -command mediabar::refineRight -width 30 -height 30]
		help $refineRightBtn balloon [mc refineRight]

		variable forwardBtn
		set forwardBtn [button $frame.forward -image mediabar::forwardImg -command mediabar::forward -width 30 -height 30]
		help $forwardBtn balloon [mc nextKeyFrame]

		variable pauseBtn
		variable pauseBtnState
		set pauseBtn [button $frame.pause -width 30 -height 30]
		set pauseBtnState 0
		switchPauseBtnMode

		variable timeScl
		set timeScl [scale $frame.time -orient horizontal -showvalue false -variable mediabar::time -command mediabar::onTimeScaleChange]

		variable volumeScl
		set volumeScl [scale $frame.volume -orient horizontal -length 50 -variable mediabar::volume -command mediabar::setVolume]
		help $volumeScl balloon [mc volume]

		variable muteBtn
		variable muteBtnState
		set muteBtn [button $frame.mute -width 30 -height 30]
		set muteBtnState 0
		switchMuteBtnMode

		bind . "<Key-Down>" mediabar::rewind
		bind . "<Key-KP_Down>" mediabar::rewind
		bind . "<Key-Up>" mediabar::forward
		bind . "<Key-KP_Up>" mediabar::forward
		bind . "<Key-Left>" mediabar::refineLeft
		bind . "<Key-Right>" mediabar::refineRight

		setEnabled 0

		pack $pauseBtn -side left
		pack $muteBtn -side right
		pack $volumeScl -side right
		pack $forwardBtn -side right
		pack $refineRightBtn -side right
		pack $refineLeftBtn -side right
		pack $rewindBtn -side right
		pack $timeScl -side left -fill x -expand true
	}

	proc makePosition {millis {actual ""}} {
		if {$actual eq ""} {
			set actual $millis
		}
		return [list $millis $actual]
	}

	proc copyPosition {pos} {
		return [list [lindex $pos 0] [lindex $pos 1]]
	}

	proc getRequested {pos} {
		set req [lindex $pos 0]
		set act [lindex $pos 1]
		if {$req < 0} {
			return $act
		}
		return $req
	}

	proc getActual {pos} {
		return [lindex $pos 1]
	}

	proc setActual {pos val} {
		return [list [lindex $pos 0] $val]
	}

	proc getCurrentPosition {} {
		variable time
		return [makePosition $time]
	}

	proc updateNavButtons {} {
		variable mediaEnabled
		variable pauseBtnState
		variable rewindBtn
		variable forwardBtn
		variable refineLeftBtn
		variable refineRightBtn
		if {$mediaEnabled && $pauseBtnState == 1} {
			set navState "normal"
		} else {
			set navState "disabled"
		}
		foreach x [list $rewindBtn $forwardBtn $refineLeftBtn $refineRightBtn] {
			$x config -state $navState
		}
	}

	proc switchPauseBtnMode {} {
		variable pauseBtn
		variable pauseBtnState
		switch -exact -- $pauseBtnState {
			0 {
				$pauseBtn config -image mediabar::pauseImg -command {set mediabar::pauseBtnState 1; mediabar::switchPauseBtnMode; player::pause}
				help $pauseBtn balloon [mc pause]
			}
			1 {
				$pauseBtn config -image mediabar::playImg -command {set mediabar::refine ""; set mediabar::pauseBtnState 0; mediabar::switchPauseBtnMode; player::play}
				help $pauseBtn balloon [mc play]
			}
		}
		updateNavButtons
	}

	proc switchMuteBtnMode {} {
		variable muteBtn
		variable muteBtnState
		switch -exact -- $muteBtnState {
			0 {
				$muteBtn config -image mediabar::unmuteImg -command {set mediabar::muteBtnState 1; mediabar::switchMuteBtnMode; player::setMute true}
				help $muteBtn balloon [mc mute]
			}
			1 {
				$muteBtn config -image mediabar::muteImg -command {set mediabar::muteBtnState 0; mediabar::switchMuteBtnMode; player::setMute false}
				help $muteBtn balloon [mc unmute]
			}
		}
	}

	proc setTime {value} {
		variable pauseBtnState
		if {$pauseBtnState == 0} {
			variable updatingTimeScale
			set updatingTimeScale 1
			variable time
			set time $value
			set updatingTimeScale 0
		}
	}

	proc onTimeScaleChange {millis} {
		variable updatingTimeScale
		if {$updatingTimeScale} {
			return
		}
		variable refine
		set refine ""
		goTo $millis
	}

	proc previousKeyFrame {t} {
		variable keyFrames
		if {[llength $keyFrames] == 0} {
			return ""
		}
		lassign [getInterval $t] left right
		if {$left < 0} {
			return ""
		}
		if {[lindex $keyFrames $left] < $t} {
			set i $left
		} elseif {$left > 0} {
			set i [expr $left - 1]
		} else {
			return ""
		}
		return [lindex $keyFrames $i]
	}

	proc nextKeyFrame {t} {
		variable keyFrames
		if {[llength $keyFrames] == 0} {
			return ""
		}
		lassign [getInterval $t] left right
		if {$right < 0} {
			return ""
		}
		return [lindex $keyFrames $right]
	}

	proc rewind {} {
		set prev [previousKeyFrame [getActual [getCurrentPosition]]]
		if {$prev eq ""} {
			return
		}
		variable refine
		set refine ""
		goTo $prev
	}

	proc forward {} {
		set next [nextKeyFrame [getActual [getCurrentPosition]]]
		if {$next eq ""} {
			return
		}
		variable refine
		set refine ""
		goTo $next
	}

	proc refineLeft {} {
		variable refine
		if {$refine eq ""} {
			set r [copyPosition [getCurrentPosition]]
			set prev [previousKeyFrame [getActual $r]]
			if {$prev eq ""} {
				set l [makePosition 0]
			} else {
				set l [makePosition $prev]
			}
			set refine [list $l $r]
		}
		refineToMidpoint 1
	}

	proc refineRight {} {
		variable refine
		variable duration
		if {$refine eq ""} {
			set l [copyPosition [getCurrentPosition]]
			set next [nextKeyFrame [getActual $l]]
			if {$next eq ""} {
				set r [makePosition $duration]
			} else {
				set r [makePosition $next]
			}
			set refine [list $l $r]
		}
		refineToMidpoint 0
	}

	proc refineContains {refineState pos} {
		set act [getActual $pos]
		set l [lindex $refineState 0]
		set r [lindex $refineState 1]
		return [expr {$act >= [getActual $l] && $act <= [getActual $r]}]
	}

	proc refineIsDegenerate {refineState} {
		set l [lindex $refineState 0]
		set r [lindex $refineState 1]
		return [expr {[getRequested $l] == [getRequested $r]}]
	}

	proc refineToMidpoint {onRefineLeft} {
		variable refine
		set startPosition [copyPosition [getCurrentPosition]]
		if {![refineContains $refine $startPosition]} {
			return
		}
		if {[refineIsDegenerate $refine]} {
			return
		}
		set l [lindex $refine 0]
		set r [lindex $refine 1]
		if {$onRefineLeft} {
			set l [lindex $refine 0]
			set r $startPosition
		} else {
			set l $startPosition
			set r [lindex $refine 1]
		}
		set c [expr {([getRequested $l] + [getRequested $r]) / 2}]
		if {[getRequested $l] < $c} {
			goTo $c
		} elseif {$onRefineLeft} {
			goTo [getRequested $l]
			set l [setActual $l [getActual [getCurrentPosition]]]
		} else {
			goTo [getRequested $r]
			set r [setActual $r [getActual [getCurrentPosition]]]
		}
		set newPosition [copyPosition [getCurrentPosition]]
		if {[getActual $startPosition] == [getActual $newPosition]} {
			if {$onRefineLeft} {
				goTo [getRequested $l]
				set l [setActual $l [getActual [getCurrentPosition]]]
			} else {
				goTo [getRequested $r]
				set r [setActual $r [getActual [getCurrentPosition]]]
			}
			set newPosition [copyPosition [getCurrentPosition]]
		}
		if {[getActual $l] > [getActual $newPosition]} {
			set l $newPosition
		}
		if {[getActual $r] < [getActual $newPosition]} {
			set r $newPosition
		}
		set refine [list $l $r]
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
			player::goTo $millis
			variable updatingTimeScale
			set updatingTimeScale 1
			variable time
			set time $millis
			set updatingTimeScale 0
		}
	}

	proc setVolume {vol} {
		player::setVolume $vol
	}

	proc reset {aDuration paused millis vol mute frames} {
		variable duration
		set duration $aDuration
		variable timeScl
		$timeScl config -from 0 -to $aDuration
		variable pauseBtnState
		if {$paused} {
			set pauseBtnState 1
		} else {
			set pauseBtnState 0
		}
		variable refine
		set refine ""
		variable mediaEnabled
		set mediaEnabled 1
		switchPauseBtnMode
		variable updatingTimeScale
		set updatingTimeScale 1
		variable time
		set time $millis
		set updatingTimeScale 0
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

	proc setEnabled {value} {
		variable mediaEnabled
		set mediaEnabled $value
		variable pauseBtn
		variable timeScl
		variable volumeScl
		variable muteBtn
		if {$value > 0} {
			set state "normal"
		} else {
			set state "disabled"
		}
		foreach x [list $pauseBtn $timeScl $volumeScl $muteBtn] {
			$x config -state $state
		}
		updateNavButtons
	}
}
