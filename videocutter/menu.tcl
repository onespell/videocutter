proc addMenuItem {menuItem index label command sequence accText} {
	$menuItem add command -label $label -command $command
	bind . $sequence [list invokeMenu $menuItem $index]
	$menuItem entryconfigure $index -accelerator $accText
}

proc invokeMenu {m index} {
	set state [$m entrycget $index -state]
	if {[string equal $state normal]} {
		$m invoke $index
	}
}

proc quit {} {
	set b [jobBox::isEmpty]
	if {!$b} {
		set choice [tk_dialog .dlg {} [mc confirmExitQuestion] {} 1 [mc yes] [mc no]]
		set b [expr $choice eq 0]
	}
	if {$b} {
		log::close
		player::closeSession
		exit
	}
}


menu .menubar
. config -menu .menubar

set fileMenuItem [menu .menubar.fileMenuItem]
.menubar add cascade -label [mc file] -menu .menubar.fileMenuItem
addMenuItem $fileMenuItem 1 [mc open] {set filePath [tk_getOpenFile -initialdir $session::workingDir -filetypes $session::fileTypes]; if {$filePath != ""} {session::setWorkingDir [file dirname $filePath]; player::loadFile $filePath 0}} "<Control-o>" "Ctrl-O"
addMenuItem $fileMenuItem 2 [mc close] {player::closeSession} "<Control-w>" "Ctrl-W"
addMenuItem $fileMenuItem 3 [mc quit] {quit} "<Control-q>" "Ctrl-Q"
