namespace eval shotBox {
	namespace export init frame setTime

	variable frame
	variable imageFormat WEBP
	variable imageFormatBox
	variable time -1
	variable timeLbl

	proc init {parent} {
		variable frame
		set frame [frame $parent.frameShotBox -relief groove -borderwidth 1 -padx 5 -pady 5]

		variable imageFormatBox
		set imageFormatBox [ttk::combobox $frame.format -textvariable shotBox::imageFormat -values $setting::imageFormats]

		set frame1 [frame $frame.frame1]
		set freezeBtn [button $frame1.button -text [mc freezeFrame] -command {jobBox::add [job::newShotJob $shotBox::time [$shotBox::imageFormatBox get]]}]
		variable timeLbl
		set timeLbl [label $frame1.time]

		pack $freezeBtn -side left
		pack $timeLbl -side left -fill x -expand true
		pack $imageFormatBox $frame1 -side top -fill x -expand true
	}

	proc setTime {value} {
		variable time
		variable timeLbl
		set time $value
		$timeLbl config -text [util::toTimeCode $value]
	}
}
