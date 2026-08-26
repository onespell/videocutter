namespace eval viewer {
	namespace export init setSize frame video updateMinSize

	variable frame
	variable videoArea
	variable video
	variable nativeWidth
	variable nativeHeight
	variable configureAfterId

	proc init {workdir parent} {
		variable frame
		variable videoArea
		set frame [frame $parent.framePlayer]

		mediabar::init $workdir $frame

		set videoArea [frame $frame.videoArea -bg black]
		grid $videoArea -row 0 -column 0 -sticky nsew
		grid $mediabar::frame -row 1 -column 0 -sticky ew
		grid rowconfigure $frame 0 -weight 1
		grid columnconfigure $frame 0 -weight 1
		bind $videoArea <Configure> [list viewer::onAreaConfigure %W]
	}

	proc setSize {width height} {
		variable videoArea
		variable video
		variable nativeWidth
		variable nativeHeight
		set nativeWidth $width
		set nativeHeight $height
		if {[info exists video] && [winfo exists $video]} {
			destroy $video
		}
		set video [frame $videoArea.video -container yes -bg black]
		pack propagate $video 0
		updateVideoGeometry
		update idletasks
	}

	proc updateVideoGeometry {} {
		variable videoArea
		variable video
		variable nativeWidth
		variable nativeHeight
		if {![info exists video] || ![winfo exists $video]} {
			return
		}
		if {![info exists nativeWidth] || ![info exists nativeHeight]} {
			return
		}
		set availW [winfo width $videoArea]
		set availH [winfo height $videoArea]
		if {$availW < 2 || $availH < 2} {
			return
		}
		set scale [expr {min(1.0, min($availW / double($nativeWidth), $availH / double($nativeHeight)))}]
		set dispW [expr {max(1, int($nativeWidth * $scale))}]
		set dispH [expr {max(1, int($nativeHeight * $scale))}]
		$video configure -width $dispW -height $dispH
		place $video -in $videoArea -relx 0.5 -rely 0.5 -anchor center -width $dispW -height $dispH
	}

	proc onAreaConfigure {w} {
		variable videoArea
		variable configureAfterId
		if {$w ne $videoArea} {
			return
		}
		if {[info exists configureAfterId]} {
			after cancel $configureAfterId
		}
		set configureAfterId [after 50 viewer::updateVideoGeometry]
	}

	proc updateMinSize {} {
		update idletasks
		set minH [expr {[winfo reqheight $mediabar::frame] + 120}]
		set minW [expr {[winfo reqwidth $toolBox::frame] + 320}]
		wm minsize . $minW $minH
	}
}
