#!/usr/bin/wish

package require Tcl 8.6
package require tksvg
package require BWidget
package require Thread
interp alias {} help {} DynamicHelp::register

set workdir [file dirname [file normalize [info script]]]
source $workdir/size.tcl
source $workdir/settings.tcl
source $workdir/session.tcl
source $workdir/analysis.tcl
source $workdir/stream.tcl
source $workdir/util.tcl
source $workdir/player.tcl
source $workdir/job.tcl
source $workdir/wid.tcl
source $workdir/log.tcl
source $workdir/file.tcl
source $workdir/dts.tcl
source $workdir/pts.tcl
source $workdir/l10n.tcl
source $workdir/menu.tcl
source $workdir/toolbox.tcl
source $workdir/viewer.tcl
source $workdir/shotbox.tcl
source $workdir/clipbox.tcl
source $workdir/jobbox.tcl
source $workdir/mediabar.tcl

msgcat::mclocale $setting::locale
session::init $setting::initialDir $setting::fileTypes $setting::defaultVolume
log::init

# compose window
wm title . "videocutter"
toolBox::init .
viewer::init $workdir .
pack $toolBox::frame -side right
pack $viewer::frame -side right -fill both -expand true

player::init

#player::loadFile "../test/test2.mkv" 0
#player::loadFile "../test/test.mp4" 0
#return

for {set i 0} {$i < [expr $argc - 1]} {incr i +1} {
	switch -exact -- [lindex $argv $i] {
		"-report" {setting::setFfmpegReport "on"}
	}
}
if {$argc >= 1} {
	set filePath [lindex $argv [expr $argc - 1]]
	player::loadFile $filePath 0
}
