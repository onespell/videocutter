namespace eval dts {
	namespace export getKeyFrames

	variable result
	variable finished

	proc getKeyFrames {filePath} {
		variable result
		variable finished
		set result {}
		set finished "n"
		set numOfThreads [util::numOfFfprobeThreads]
		set input [open "| $setting::ffprobePath -threads $numOfThreads -select_streams v -skip_frame nokey -show_frames -show_entries frame=pkt_dts_time -of csv=p=0 -v quiet $filePath" r]
		fileevent $input readable [list dts::read $input]
		vwait dts::finished
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
		set p [string first "," $line]
		if {$p < 0} {
			set s $line
		} else {
			set s [string range $line 0 [expr $p - 1]]
		}
		if {[string length $s] > 0} {
			if {[catch {set millis [util::toMillis $s]} r]} {
				return
			}
			variable result
			lappend result $millis
		}
	}
}
