namespace eval clipBox {
	namespace export init frame setDuration setTime setFormat setVideoStream setAudioStreams

	variable frame
	variable size
	variable defaultSize
	variable sizes
	variable videoStream
	variable audio
	variable defaultAudio
	variable audioStreams
	variable format AVI
	variable duration -1
	variable time -1
	variable a -1
	variable b -1
	variable aLbl
	variable bLbl
	variable sizeBox
	variable audioBox
	variable formatBox

	proc init {parent} {
		variable frame
		set frame [frame $parent.frameClipBox -relief groove -borderwidth 1 -padx 5 -pady 5]

		set frameA [frame $frame.frameA]
		set aBtn [button $frameA.button -text "A \[" -command {clipBox::setA $clipBox::time}]
		variable aLbl
		set aLbl [label $frameA.label]

		set frameB [frame $frame.frameB]
		set bBtn [button $frameB.button -text "\] B" -command {clipBox::setB $clipBox::time}]
		variable bLbl
		set bLbl [label $frameB.label]

		variable sizeBox
		variable audioBox
		variable formatBox
		set sizeBox [ttk::combobox $frame.size -textvariable clipBox::size]
		set audioBox [ttk::combobox $frame.audio -textvariable clipBox::audio]
		set formatBox [ttk::combobox $frame.format -textvariable clipBox::format -values $setting::videoFormats]
		set cutBtn [button $frame.cut -text [mc cut] -command {jobBox::add [clipBox::newJob]}]

		pack $aBtn -side left
		pack $aLbl -side left -fill x -expand true
		pack $bBtn -side left
		pack $bLbl -side left -fill x -expand true
		pack $frameA $frameB $sizeBox $audioBox $formatBox $cutBtn -side top -fill x -expand true
	}

	proc newJob {} {
		variable a
		variable b
		variable format
		variable size
		variable defaultSize
		variable sizes
		variable videoStream
		variable audio
		variable defaultAudio
		variable audioStreams
		if {$size eq $defaultSize} {
			set pSize ""
		} else {
			set pSize [dict get $sizes $size]
		}
		if {$audio eq $defaultAudio} {
			set pAudio ""
		} else {
			set pAudio [dict get $audioStreams $audio]
		}
		return [job::newClipJob $a $b $format $pSize $videoStream $pAudio]
	}

	proc setA {value} {
		variable aLbl
		variable a
		variable b
		set a $value
		$aLbl config -text [util::toTimeCode $a]
		if {$b < $a} {
			variable duration
			setB $duration
		}
	}

	proc setB {value} {
		variable bLbl
		variable a
		variable b
		set b $value
		$bLbl config -text [util::toTimeCode $b]
		if {$b < $a} {
			setA 0
		}
	}

	proc setTime {value} {
		variable time
		set time $value
	}

	proc setDuration {value} {
		variable duration
		set duration $value
	}

	proc setFormat {value} {
		variable format
		set format $value
	}

	proc setSizes {value} {
		variable size
		variable defaultSize
		variable sizes
		variable sizeBox
		set sizes [dict create]
		if {[info exists size]} {
			unset size
		}
		if {[info exists defaultSize]} {
			unset defaultSize
		}
		set listValues {}
		foreach x $value {
			set c [size::toString $x]
			dict append sizes $c $x
			lappend listValues $c
			if {![info exists size]} {
				set size $c
				set defaultSize $c
			}
		}
		$sizeBox config -values $listValues
	}

	proc setVideoStream {value} {
		variable videoStream
		set videoStream $value
	}

	proc setAudioStreams {value} {
		variable audio
		variable defaultAudio
		variable audioStreams
		variable audioBox
		set audioStreams [dict create]
		if {[info exists audio]} {
			unset audio
		}
		if {[info exists defaultAudio]} {
			unset defaultAudio
		}
		set listValues {}
		set nosound [stream::newAudioStream "" [mc noSound]]
		dict append audioStreams [stream::getCaption $nosound] $nosound
		lappend listValues [stream::getCaption $nosound]
		foreach x $value {
			set c [stream::getCaption $x]
			dict append audioStreams $c $x
			lappend listValues $c
			if {![info exists audio]} {
				set audio $c
				set defaultAudio $c
			}
		}
		$audioBox config -values $listValues
	}
}