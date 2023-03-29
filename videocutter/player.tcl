source $workdir/mplayer.tcl
source $workdir/mpv.tcl

namespace eval player {
	namespace export isPaused setPaused loadFile pause play setVolume setMute goTo closeSession

	variable p
	variable paused

	proc init {} {
		variable p
		switch -exact -- $setting::player {
			mpv {set p "mpv"}
			mplayer {set p "mplayer"}
		}
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
		variable p
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
		eval [list "${p}::setInOut" $aFilePath $position]
		set paused 1
		if {$setting::muteOnStart} {
			setMute true
		}
		if {$session::volume > 0} {
			setVolumeForcibly $session::volume
		}
		goTo 0
		mediabar::reset $duration $paused 0 $session::volume [eval [list "${p}::isMuted"]] $keyFrames
		shotBox::reset
		jobBox::reset
		mediabar::setEnabled 1
		toolBox::setEnabled 1
		log::info "open $filePath"
		wid::destroySplash $splash
	}

	proc pause {} {
		variable paused
		if {!$paused} {
			set paused 1
			variable p
			set cmd [list "${p}::pause"]
			eval $cmd
		}
	}

	proc play {} {
		variable paused
		if {$paused} {
			set paused 0
			variable p
			set cmd [list "${p}::play"]
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
		variable p
		set cmd [list "${p}::setVolume" $vol]
		eval $cmd
	}

	proc setMute {flag} {
		variable p
		set cmd [list "${p}::setMute" $flag]
		eval $cmd
	}

	proc goTo {millis} {
		variable p
		set cmd [list "${p}::goTo" $millis]
		eval $cmd
		shotBox::setTime $millis
		clipBox::setTime $millis
	}

	proc closeSession {} {
		variable p
		set cmd [list "${p}::closeSession"]
		eval $cmd
	}
}
