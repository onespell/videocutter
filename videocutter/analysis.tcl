namespace eval analysis {
	namespace export getFormat getDuration getFrameSizes getKeyFrames getMediaStreams

	proc getFormat {filePath} {
		set ext [file extension {*}$filePath]
		set len [string length $ext]
		return [string toupper [string range $ext 1 [expr $len - 1]]]
	}

	proc getFrameSizes {filePath} {
		set input [open "| $setting::ffprobePath -v error -select_streams v -show_entries stream=width,height,display_aspect_ratio -of csv=p=0 $filePath" r]
		foreach line [split [read $input] \n] {
			set list [split $line ,]
			set width [lindex $list 0]
			set height [lindex $list 1]
			if {[catch {set ratio [lindex $list 2]}] || $ratio eq "N/A"} {
				set gcd [util::gcd $width $height]
				set ratio [format "%d:%d" [expr int($width / $gcd)] [expr int($height / $gcd)]]
			}
			break
		}
		close $input
		set result {}
		lappend result [size::newSize $width $height]
		if {[catch {set alternatives [dict get $setting::aspectRatios $ratio]}]} {
			set alternatives {}
		}
		foreach alternative $alternatives {
			if {$width > [size::getWidth $alternative]} {
				lappend result $alternative
			}
		}
		foreach alternative $setting::ratioWildcards {
			set w [size::getWidth $alternative]
			set h [size::getHeight $alternative]
			if {$w eq "*"} {
				if {$height > $h} {
					lappend result $alternative
				}
			} elseif {$width > $w} {
				lappend result $alternative
			}
		}
		return $result
	}

	proc getMediaStreams {filePath} {
		set video {}
		set audio {}
		set numOfThreads [util::numOfFfprobeThreads]
		set input [open "| $setting::ffprobePath -threads $numOfThreads -v quiet -show_entries stream=index,codec_type:stream_tags=language,title -of csv=p=0 $filePath" r]
		foreach line [split [read $input] \n] {
			set s [split $line ,]
			set id [lindex $s 0]
			set type [string range [lindex $s 1] 0 0]
			set caption [getStreamCaption $id $type $s]
			switch -exact -- $type {
				a {lappend audio [stream::newAudioStream $id $caption]}
				v {lappend video [stream::newVideoStream $id $caption]}
			}
		}
		close $input
		return [list $video $audio]
	}

	proc getStreamCaption {id type splitted} {
		set result {}
		set len [llength $splitted]
		switch -exact -- $type {
			a {append result "audio "}
			v {append result "video "}
			default {}
		}
		append result $id
		if {$len > 2} {
			set lang [lindex $splitted 2]
			if {$lang ne "und"} {
				append result " "
				append result $lang
			}
		}
		if {$len > 3} {
			set title [lindex $splitted 3]
			append result " "
			append result $title
		}
		return $result
	}

	proc getKeyFrames {filePath} {
		set result [pts::getKeyFrames $filePath]
		if {[llength $result] == 0} {
			set candidate [dts::getKeyFrames $filePath]
			if {[llength $result] == 0 || [lindex $candidate 0] == 0} {
				set result $candidate
			}
		}
		if {[llength $result] == 0} {
			tk_messageBox -type ok -icon error -message [mc noKeyFrames]
		}
		return $result
	}

	proc getDuration {filePath} {
		set input [open "| $setting::ffprobePath -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $filePath" r]
		set duration [lindex [split [read $input] \n] 0]
		close $input
		if {$duration ne ""} {
			set result [util::toMillis $duration]
		} else {
			set result 0
		}
		return $result
	}

}
