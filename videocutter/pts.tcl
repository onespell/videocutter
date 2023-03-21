namespace eval pts {
	namespace export getKeyFrames

	variable result
	variable finished

	proc getKeyFrames {filePath} {
		variable result
		variable finished
		set result {}
		set finished "n"
		set numOfThreads [util::numOfFfprobeThreads]
		set input [open "| $setting::ffprobePath -threads $numOfThreads -select_streams v -show_packets -show_entries packet=pts_time,flags -of csv=p=0 -v quiet $filePath" r]
		fileevent $input readable [list pts::read $input]
		vwait pts::finished
		if {[util::isNotValid $result]} {
			set result {}
		}
		return $result
	}

	proc read {pipe} {
		if {[eof $pipe]} {
			catch {close $pipe}
			variable finished
			set finished "y"
			return
		}
		gets $pipe line
		set split [split $line ","]
		set flag [string range [lindex $split 1] 0 0]
		if {$flag ne "K"} {
			return
		}
		set s [lindex $split 0]
		if {[string length $s] <= 0 || [catch {set millis [util::toMillis $s]} r]} {
			return
		}
		variable result
		lappend result $millis
	}
}
