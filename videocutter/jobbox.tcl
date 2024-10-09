switch -exact -- $setting::imageTool {
	ffmpeg {
		source $workdir/img_ffmpeg.tcl
	}
	mpv {
		source $workdir/img_mpv.tcl
	}
	cwebp {
		source $workdir/img_cwebp.tcl
	}
}

namespace eval jobBox {
	namespace export frame init reset add isEmpty insertJobs unmarshallClipJob setEnabled

	variable frame
	variable dryRun
	variable list
	variable items {}
	variable shotJobPrefix "frame"
	variable clipJobPrefix "clip"
	variable videoPrefix "v:"
	variable audioPrefix "a:"
	variable noSound "no"
	variable dryRunChk
	variable runBtn

	proc init {parent} {
		variable frame
		set frame [frame $parent.frameJobBox -relief groove -borderwidth 1 -padx 5 -pady 5]

		variable list
		# set list [listbox $frame.list -selectmode extended]
		set list [wid::scrolledListbox $frame.scrolledList -selectmode extended -width 40 -height 1000]

		set frame1 [frame $frame.frame1]
		variable dryRun
		set dryRun 0
		variable dryRunChk
		set dryRunChk [checkbutton $frame1.dryrun -text [mc dryRun] -variable jobBox::dryRun]
		variable runBtn
		set runBtn [button $frame1.button -text [mc run] -command jobBox::run]

		bind $list "<Delete>" jobBox::onDelete
		bind $list "<KP_Delete>" jobBox::onDelete
		bind $list "<Double-1>" {
			set selected [$jobBox::list curselection]
			set idx [lindex $selected 0]
			set job [lindex $jobBox::items $idx]
			set t [job::getTime $job]
			mediabar::goTo $t
		}

		setEnabled 0

		pack $dryRunChk -side left
		pack $runBtn -side left -fill x -expand true
		pack $frame1 -side bottom -fill x -expand true
		pack $frame.scrolledList -side bottom -fill both -expand true
	}

	proc run {} {
		variable items
		set numOfJobs [llength $items]
		if {$numOfJobs == 0} {
			return
		}
		set sorted [lsort -command compareJobs $items]
		variable dryRun
		if {$dryRun} {
			set msg {}
			foreach job $sorted {
				set type [job::getJobType $job]
				if {$type eq $job::shotJobType} {
					append msg [doShotJob $job $dryRun $numOfJobs]
					append msg "\n\n"
				} elseif {$type eq $job::clipJobType} {
					append msg [doClipJob $job $dryRun $numOfJobs]
					append msg "\n\n"
				}
			}
			wid::showLogSplash $msg
		} else {
			set splash [wid::showProgressSplash [mc executing] [llength $items]]
			set result 0
			foreach job $sorted {
				set type [job::getJobType $job]
				if {$type eq $job::shotJobType} {
					set result [doShotJob $job $dryRun $numOfJobs]
				} elseif {$type eq $job::clipJobType} {
					set result [doClipJob $job $dryRun $numOfJobs]
				}
				if {$result} {
					break
				}
				wid::incrProgress 1
			}
			if {$result} {
				tk_messageBox -type ok -icon error -message [mc jobFail]
			} else {
				reset
			}
			wid::destroySplash $splash
		}
	}

	proc compareJobs {x y} {
		set timeX [job::getTime $x]
		set timeY [job::getTime $y]
		if {$timeX < $timeY} {
			return -1
		} elseif {$timeX > $timeY} {
			return 1
		} else {
			return 0
		}
	}

	proc doShotJob {job dryRun numOfJobs} {
		set sourceFile $session::filePath
		set format [job::getFormat $job]
		set resultFile [file::getNext {*}$sourceFile $format $numOfJobs]
		return [img::convert $job $format $sourceFile $resultFile $dryRun]
	}

	proc doClipJob {job dryRun numOfJobs} {
		set ffmpegPath $setting::ffmpegPath
		set sourceFile $session::filePath
		set format [job::getFormat $job]
		set resultFile [file::getNext {*}$sourceFile $format $numOfJobs]
		set numOfThreads [util::numOfFfprobeThreads]
		set cmd [list $ffmpegPath]
		if {$setting::ffmpegReport eq "on"} {
			lappend cmd "-report"
		}
		lappend cmd "-threads" $numOfThreads "-i" {*}$sourceFile "-ss" [util::toTimeCode [job::getTime $job]] "-to" [util::toTimeCode [job::getFinish $job]]
		set frameSize [job::getSize $job]
		if {$frameSize eq ""} {
			lappend cmd "-c" "copy"
		} else {
			set w [size::getWidth $frameSize]
			if {$w eq "*"} {
				set w "trunc(oh*a/2)*2"
			}
			set h [size::getHeight $frameSize]
			if {$h eq "*"} {
				set h "trunc(ow/a/2)*2"
			}
			set vcodec "libx264"
			if {[string tolower $format] eq "webm"} {
				set vcodec "libvpx-vp9"
			}
			lappend cmd "-vf" [format "scale=%s:%s" $w $h] "-c:v" $vcodec "-crf" "18" "-preset" "veryslow" "-c:a" "copy" "-c:s" "copy"
		}
		set audio [job::getAudio $job]
		if {$audio ne ""} {
			set audioId [stream::getId $audio]
			if {$audioId eq ""} {
				lappend cmd "-an"
			} else {
				set video [job::getVideo $job]
				set videoId [stream::getId $video]
				lappend cmd "-map" [format "0:%s" $videoId]
				lappend cmd "-map" [format "0:%s" $audioId]
			}
		} else {
			lappend cmd "-map" "0"
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

	proc isEmpty {} {
		variable items
		return [expr [llength $items] == 0]
	}

	proc onDelete {} {
		set choice [tk_dialog .dlg [mc confirmDeleteTitle] [mc confirmDeleteQuestion] {} 1 [mc yes] [mc no]]
		if {$choice eq 0} {
			variable list
			variable items
			set selected [$list curselection]
			set numOfSelected [llength $selected]
			for {set i [expr $numOfSelected - 1]} {$i >= 0} {incr i -1} {
				set idx [lindex $selected $i]
				$list delete $idx
				set items [lreplace $items $idx $idx]
			}
		}
		toolBox::onSelect
	}

	proc reset {} {
		variable list
		variable items
		set items {}
		$list delete 0 [expr [$list size] - 1]
	}

	proc add {job} {
		variable list
		variable items
		$list insert end [toString $job]
		$list yview end
		lappend items $job
		log::info [marshall $job]
	}

	proc toString {job} {
		set type [job::getJobType $job]
		if {$type eq $job::shotJobType} {
			set result [format "<%s> %s" [util::toTimeCode [job::getTime $job]] [job::getFormat $job]]
		} elseif {$type eq $job::clipJobType} {
			set result [format "\[%s-%s\]" [util::toTimeCode [job::getTime $job]] [util::toTimeCode [job::getFinish $job]]]
			set size [job::getSize $job]
			if {$size ne ""} {
				append result " "
				append result [size::toString $size]
			}
			set audioStream [job::getAudio $job]
			if {$audioStream ne ""} {
				append result " a:"
				set audioStreamId [stream::getId $audioStream]
				if {$audioStreamId eq ""} {
					append result "no"
				} else {
					append result $audioStreamId
				}
			}
			append result " "
			append result [job::getFormat $job]
		}
		return $result
	}

	proc marshall {job} {
		set type [job::getJobType $job]
		if {$type eq $job::shotJobType} {
			variable shotJobPrefix
			set result [format "%s %s %s" $shotJobPrefix [util::toTimeCode [job::getTime $job]] [job::getFormat $job]]
		} elseif {$type eq $job::clipJobType} {
			variable clipJobPrefix
			variable videoPrefix
			variable audioPrefix
			variable noSound
			set result [format "%s %s-%s" $clipJobPrefix [util::toTimeCode [job::getTime $job]] [util::toTimeCode [job::getFinish $job]]]
			set size [job::getSize $job]
			if {$size ne ""} {
				append result " "
				append result [size::toString $size]
			}
			set video [job::getVideo $job]
			set videoId [stream::getId $video]
			append result [format " %s%s" $videoPrefix $videoId]
			set audio [job::getAudio $job]
			if {$audio ne ""} {
				append result " "
				append result $audioPrefix
				set audioId [stream::getId $audio]
				if {$audioId eq ""} {
					append result "no"
				} else {
					append result $audioId
				}
			}
			append result " "
			append result [job::getFormat $job]
		}
		return $result
	}

	proc unmarshallShotJob {str} {
		variable shotJobPrefix
		set p [string last " " $str]
		set timeCode [string trim [string range $str [string length $shotJobPrefix] $p]]
		set format [string trim [string range $str [expr $p + 1] [expr [string length $str] - 1]]]
		return [job::newShotJob [util::fromTimeCode $timeCode] $format]
	}

	proc unmarshallClipJob {str} {
		variable clipJobPrefix
		variable videoPrefix
		variable audioPrefix
		set p [string length $clipJobPrefix]
		set q [string first "-" $str $p]
		set start [util::fromTimeCode [string trim [string range $str [expr $p + 1] [expr $q - 1]]]]
		set p [expr $q + 1]
		set q [string first " " $str $p]
		set finish [util::fromTimeCode [string trim [string range $str $p $q]]]
		set p [expr $q + 1]
		set split [split [string range $str $p [expr [string length $str] - 1]] " "]
		set videoPrefixLength [string length $videoPrefix]
		set audioPrefixLength [string length $audioPrefix]
		set video ""
		set audio ""
		set size ""
		for {set i 0} {$i < [expr [llength $split] - 1]} {incr i +1} {
			set chunk [lindex $split $i]
			set lastCharIndex [expr [string length $chunk] - 1]
			if {[string range $chunk 0 [expr $videoPrefixLength - 1]] eq $videoPrefix} {
				set videoId [string trim [string range $chunk $videoPrefixLength $lastCharIndex]]
				set videoCaption [format "video %s" $videoId]
				set video [stream::newVideoStream $videoId $videoCaption]
			} elseif {[string range $chunk 0 [expr $audioPrefixLength - 1]] eq $audioPrefix} {
				set audioId [string trim [string range $chunk $audioPrefixLength $lastCharIndex]]
				set audioCaption [format "audio %s" $audioId]
				set audio [stream::newAudioStream $audioId $audioCaption]
			} else {
				set x [string first "x" $chunk]
				set width [string trim [string range $chunk 0 [expr $x - 1]]]
				set height [string trim [string range $chunk [expr $x + 1] $lastCharIndex]]
				set size [size::newSize $width $height]
			}
		}
		set format [lindex $split [expr [llength $split] - 1]]
		return [job::newClipJob $start $finish $format $size $video $audio]
	}

	proc insertJobs {lines} {
		variable shotJobPrefix
		variable clipJobPrefix
		foreach str [split $lines "\n"] {
			set p [string first $shotJobPrefix $str]
			if {$p >= 0} {
				add [unmarshallShotJob [string range $str $p [expr [string length $str] - 1]]]
				continue
			}
			set p [string first $clipJobPrefix $str]
			if {$p >= 0} {
				add [unmarshallClipJob [string range $str $p [expr [string length $str] - 1]]]
				continue
			}
			if {[string trim $str] eq ""} {
				continue
			}
			tk_messageBox -type ok -icon error -message [format "%s: %s" [mc invalidJobStr] $str]
		}
	}

	proc setEnabled {value} {
		variable list
		variable dryRunChk
		variable runBtn
		if {$value > 0} {
			set state "normal"
		} else {
			set state "disabled"
		}
		set children [list $list $dryRunChk $runBtn]
		foreach x $children {
			$x config -state $state
		}
	}
}
