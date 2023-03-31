namespace eval img {
	namespace export convert

	variable mpvPath $setting::mpvPath

	proc convert {job format sourceFile resultFile dryRun} {
		variable mpvPath
		set t [util::toTimeCode [job::getTime $job]]
		set dir [fileutil::maketempdir -prefix "vc-"]
		set cmd [list $mpvPath]
		lappend cmd "--mute=yes" "--frames=1" "--start=$t" "--vo=image" "--vo-image-outdir=$dir"
		switch -exact -- $format {
			WEBP {
				lappend cmd "--vo-image-format=webp" "--vo-image-webp-quality=80"
			}
			default {
				
			}
		}
		lappend cmd {*}$sourceFile
		if {$dryRun} {
			return $cmd
		} else {
			if {[catch {exec -ignorestderr {*}$cmd} result]} {
				return 1
			}
		}
		set f [lindex [glob -directory $dir *] 0]
		file rename $f $resultFile
		file delete $dir
		return 0
	}
}
