namespace eval conv_ffmpeg {

	variable ffmpegPath $setting::ffmpegPath

	proc convert {job format sourceFile resultFile dryRun} {
		set t [util::toTimeCode [job::getTime $job]]
		variable ffmpegPath
		set cmd [list $ffmpegPath]
		if {$setting::ffmpegReport eq "on"} {
			lappend cmd "-report"
		}
		lappend cmd "-i" {*}$sourceFile "-ss" $t "-frames:v" 1
		switch -exact -- $format {
			WEBP {
				lappend cmd "-q:v" 80 "-lossless" 0 "-compression_level" 6 "-loop" 0 "-preset" "picture"
			}
			default {
				# Normal range for JPEG is 2-31 with 31 being the worst 
				# quality. The scale is linear with double the qscale 
				# being roughly half the bitrate. Recommend trying 
				# values of 2-5.
				lappend cmd "-q:v" 2
			}
		}
		lappend cmd "-y"
		lappend cmd $resultFile
		if {$dryRun} {
			return $cmd
		} else {
			if {[catch {exec -ignorestderr {*}$cmd} result]} {
				return 1
			}
			return 0
		}
	}
}
