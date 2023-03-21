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
source $workdir/mplayer.tcl
source $workdir/job.tcl
source $workdir/wid.tcl
source $workdir/log.tcl
source $workdir/file.tcl
source $workdir/dts.tcl
source $workdir/pts.tcl
source $workdir/l10n.tcl
source $workdir/menu.tcl
source $workdir/toolbox.tcl
source $workdir/player.tcl
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
player::init $workdir .
pack $toolBox::frame -side right
pack $player::frame -side right -fill both -expand true

mplayer::init $setting::mplayerPath

# mplayer::loadFile "../test/test.mp4" 0

for {set i 0} {$i < [expr $argc - 1]} {incr i +1} {
	switch -exact -- [lindex $argv $i] {
		"-report" {setting::setFfmpegReport "on"}
	}
}
if {$argc >= 1} {
	set filePath [lindex $argv [expr $argc - 1]]
	mplayer::loadFile $filePath 0
}
