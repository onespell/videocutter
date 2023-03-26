source $workdir/mplayer.tcl
source $workdir/mpv.tcl

namespace eval player {
	namespace export loadFile pause play setVolume setMute goTo closeSession

	variable p

	proc init {} {
		variable p
		switch -exact -- $setting::player {
			mpv {set p "mpv"}
			mplayer {set p "mplayer"}
		}
	}

	proc loadFile {filePath position} {
		variable p
		set cmd [list "${p}::loadFile" $filePath $position]
		eval $cmd
	}

	proc pause {} {
		variable p
		set cmd [list "${p}::pause"]
		eval $cmd
	}

	proc play {} {
		variable p
		set cmd [list "${p}::play"]
		eval $cmd
	}

	proc setVolume {vol} {
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
	}

	proc closeSession {} {
		variable p
		set cmd [list "${p}::closeSession"]
		eval $cmd
	}
}
