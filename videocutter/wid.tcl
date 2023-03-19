namespace eval wid {
	namespace export scrolledListbox showProgressSplash showWaitSplash destroySplash showLogSplash showTextInput

	variable progress
	variable textInput

	proc scrolledListbox {f args} {
		frame $f
		listbox $f.list -xscrollcommand [list wid::scrollSet $f.xscroll [list grid $f.xscroll -row 1 -column 0 -sticky we]] -yscrollcommand [list wid::scrollSet $f.yscroll [list grid $f.yscroll -row 0 -column 1 -sticky ns]]
		eval {$f.list configure} $args
		scrollbar $f.xscroll -orient horizontal -command [list $f.list xview]
		scrollbar $f.yscroll -orient vertical -command [list $f.list yview]
		grid $f.list -sticky news
		grid rowconfigure $f 0 -weight 1
		grid columnconfigure $f 0 -weight 1
		return $f.list
	}

	proc scrollSet {scrollbar geoCmd offset size} {
		if {$offset != 0.0 || $size != 1.0} {
			eval $geoCmd;
		}
		$scrollbar set $offset $size
	}

	proc showWaitSplash {msg} {
		ProgressDlg::create .splash -title $msg -type infinite -maximum 100
	}

	proc showProgressSplash {msg max} {
		variable progress
		set progress 0
		ProgressDlg::create .splash -title $msg -variable wid::progress -type normal -maximum $max
	}

	proc incrProgress {delta} {
		variable progress
		set progress [expr $progress + 1]
	}

	proc destroySplash {splash} {
		destroy $splash
	}

	proc showLogSplash {msg} {
		set splash [toplevel .splash]
		wm title $splash ""
		set f [frame $splash.f]
		set f2 [frame $f.f2]
		set t [text $f2.t -setgrid true -wrap word]
		set sy [scrollbar $f2.sy -orient vert -command "$t yview"]
		$t config -yscrollcommand "$sy set"
		set ok [button $f.ok -text CLOSE -command {destroy .splash}]
		pack $f -side top -fill both -expand true
		pack $f2 -side top -fill both -expand true
		pack $sy -side right -fill y
		pack $t -side left -fill both -expand true
		pack $ok -side left -fill x -expand true
		catch {grab $splash}
		$t insert end $msg
		$t configure -state disabled
	}

	proc showTextInput {btnCaption callback} {
		variable textInput
		set splash [toplevel .splash]
		wm title $splash ""
		set f [frame $splash.f]
		set f2 [frame $f.f2]
		set textInput [text $f2.t -setgrid true -wrap word]
		set sy [scrollbar $f2.sy -orient vert -command "$textInput yview"]
		$textInput config -yscrollcommand "$sy set"
		set cancel [button $f.cancel -text [mc cancel] -command {destroy .splash}]
		set ok [button $f.ok -text $btnCaption -command {$wid::textInput configure -state disabled; lappend callback [$wid::textInput get 1.0 end]; eval $callback; destroy .splash}]
		pack $f -side top -fill both -expand true
		pack $f2 -side top -fill both -expand true
		pack $sy -side right -fill y
		pack $textInput -side left -fill both -expand true
		pack $cancel -side left -fill x -expand true
		pack $ok -side left -fill x -expand true
		catch {grab $splash}
		focus $textInput
	}
}
