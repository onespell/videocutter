namespace eval file {
	namespace export getNext

	proc getNext {filePath format numOfJobs} {
		set root [file rootname $filePath]
		set fmt [string tolower $format]
		set n [string length $numOfJobs]
		if {$n < 2} {
			set n 2
		}
		set i 1
		while {1} {
			set name [format "%s_%0${n}d.%s" $root $i $fmt]
			if {[file exists $name]} {
				set i [expr $i + 1]
			} else {
				break
			}
		}
		return $name
	}
}
