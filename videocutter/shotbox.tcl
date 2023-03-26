namespace eval shotBox {
	namespace export init frame setTime setEnabled reset

	variable frame
	variable imageFormat WEBP
	variable imageFormatBox
	variable time -1
	variable timeLbl
	variable freezeBtn

	proc init {parent} {
		variable frame
		set frame [frame $parent.frameShotBox -relief groove -borderwidth 1 -padx 5 -pady 5]

		variable imageFormatBox
		set imageFormatBox [ttk::combobox $frame.format -textvariable shotBox::imageFormat -values $setting::imageFormats]
		bind $imageFormatBox <<ComboboxSelected>> [list toolBox::onSelect]

		set frame1 [frame $frame.frame1]
		variable freezeBtn
		set freezeBtn [button $frame1.button -text [mc freezeFrame] -command {jobBox::add [job::newShotJob $shotBox::time [$shotBox::imageFormatBox get]]}]
		variable timeLbl
		set timeLbl [label $frame1.time]

		setEnabled 0

		pack $freezeBtn -side left
		pack $timeLbl -side left -fill x -expand true
		pack $imageFormatBox $frame1 -side top -fill x -expand true
	}

	proc setEnabled {value} {
		variable imageFormatBox
		variable freezeBtn
		if {$value > 0} {
			set state "normal"
		} else {
			set state "disabled"
		}
		set children [list $imageFormatBox $freezeBtn]
		foreach x $children {
			$x config -state $state
		}
	}

	proc setTime {value} {
		variable time
		variable timeLbl
		set time $value
		$timeLbl config -text [util::toTimeCode $value]
	}

	proc reset {} {
		variable imageFormat
		variable time
		variable timeLbl
		set imageFormat WEBP
		set time -1
		$timeLbl config -text ""
	}
}
