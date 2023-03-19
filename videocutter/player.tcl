namespace eval player {
	namespace export init setSize frame video

	variable frame
	variable video

	proc init {workdir parent} {
		variable frame
		set frame [frame $parent.framePlayer]

		variable video
		set video [frame $frame.video -container yes]
		$video config -bg black

		mediabar::init $workdir $frame
		pack $mediabar::frame -side bottom -fill x
		#pack $video -side bottom -fill both -expand true
		pack $video -side bottom
	}

	proc setSize {width height} {
		variable video
		$video config -width $width -height $height
	}
}
