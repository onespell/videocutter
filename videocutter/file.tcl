namespace eval file {
	namespace export getNext

	proc getNext {filePath format} {
		set root [file rootname $filePath]
		set fmt [string tolower $format]
		set i 1
		while {1} {
			set name [format "%s_%02d.%s" $root $i $fmt]
			if {[file exists $name]} {
				set i [expr $i + 1]
			} else {
				break
			}
		}
		return $name
	}
}
