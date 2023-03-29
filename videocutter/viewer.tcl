namespace eval viewer {
	namespace export init setSize frame video

	variable frame
	variable video

	proc init {workdir parent} {
		variable frame
		set frame [frame $parent.framePlayer]

		variable video
		createVideo

		mediabar::init $workdir $frame
		pack $mediabar::frame -side bottom -fill x
		#pack $video -side bottom -fill both -expand true
		pack $video -side bottom
	}

	proc setSize {width height} {
		variable frame
		set children [winfo children $frame]
		variable video
		if {[lsearch -exact $children $video] < 0} {
			createVideo
			pack $video -side bottom
		}
		$video config -width $width -height $height
	}

	proc createVideo {} {
		variable frame
		variable video
		set video [frame $frame.video -container yes]
		$video config -bg black
	}
}
