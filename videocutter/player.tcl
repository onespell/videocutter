switch -exact -- $setting::player {
	mpv {
		source $workdir/mpv.tcl
	}
	mplayer {
		source $workdir/mplayer.tcl
	}
}

namespace eval player {
	namespace export isPaused setPaused loadFile pause play setVolume setMute goTo closeSession

	variable paused 0

	proc init {} {
		set workdir [file dirname [file normalize [info script]]]
	}

	proc isPaused {} {
		variable paused
		return $paused
	}

	proc setPaused {value} {
		variable paused
		set paused $value
	}

	proc loadFile {aFilePath position} {
		variable duration
		variable paused
		closeSession
		mediabar::setEnabled 0
		toolBox::setEnabled 0
		set splash [wid::showWaitSplash [mc loading]]
		set filePath [list $aFilePath]
		session::setFilePath $filePath
		set sizes [analysis::getFrameSizes $filePath]
		set size [lindex $sizes 0]
		set width [size::getWidth $size]
		set height [size::getHeight $size]
		set keyFrames [analysis::getKeyFrames $filePath]
		viewer::setSize $width $height
		set duration [analysis::getDuration $filePath]
		set format [analysis::getFormat $filePath]
		lassign [analysis::getMediaStreams $filePath] videoStreams audioStreams
		clipBox::reset $format $duration $sizes [lindex $videoStreams 0] $audioStreams
		eval [list "sysplayer::setInOut" $aFilePath $position]
		mediabar::reset $duration $paused 0 $session::volume [eval [list "sysplayer::isMuted"]] $keyFrames
		shotBox::reset
		jobBox::reset
		mediabar::setEnabled 1
		toolBox::setEnabled 1
		log::info "open $filePath"
		mediabar::setTime 0
		shotBox::setTime 0
		clipBox::setTime 0
		wid::destroySplash $splash
	}

	proc pause {} {
		variable paused
		if {!$paused} {
			set paused 1
			set cmd [list "sysplayer::pause"]
			eval $cmd
		}
	}

	proc play {} {
		variable paused
		if {$paused} {
			set paused 0
			set cmd [list "sysplayer::play"]
			eval $cmd
		}
	}

	proc setVolume {vol} {
		if {$vol ne $session::volume} {
			setVolumeForcibly $vol
		}
	}

	proc setVolumeForcibly {vol} {
		session::setVolume $vol
		set cmd [list "sysplayer::setVolume" $vol]
		eval $cmd
	}

	proc setMute {flag} {
		set cmd [list "sysplayer::setMute" $flag]
		eval $cmd
	}

	proc goTo {millis} {
		set cmd [list "sysplayer::goTo" $millis]
		eval $cmd
		shotBox::setTime $millis
		clipBox::setTime $millis
	}

	proc closeSession {} {
		set cmd [list "sysplayer::closeSession"]
		eval $cmd
	}
}
