namespace eval toolBox {
	namespace export init frame

	variable frame

	proc init {parent} {
		variable frame
		set frame [frame $parent.frameToolbox -relief groove -borderwidth 1 -padx 5 -pady 5]

		set frame1 [frame $frame.frame1 -pady 5]
		set manualInputBtn [button $frame1.manualInput -text [mc manualInput] -command {set callback [list "jobBox::insertJobs"]; wid::showTextInput [mc add] $callback}]

		shotBox::init $frame
		clipBox::init $frame
		jobBox::init $frame
		pack $shotBox::frame -side top -fill x -expand true
		pack $clipBox::frame -side top -fill x -expand true
		pack $manualInputBtn -side top -fill x -expand true
		pack $frame1 -side top -fill x -expand true
		pack $jobBox::frame -side top -fill both -expand true
	}
}
