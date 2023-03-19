namespace eval util {
	namespace export extractTime toMillis toTimeCode fromTimeCode isNotValid gcd

	variable MS_IN_SECOND 1000
	variable MS_IN_MINUTE [expr 60 * $MS_IN_SECOND]
	variable MS_IN_HOUR [expr 60 * $MS_IN_MINUTE]

	proc extractTime {line} {
		if {[string range $line 0 1] eq "A:"} {
			set p [expr [string first " V:" $line] + 3]
			set q [string first " A-V:" $line $p]
			set result [string range $line $p [expr $q - 1]]
		} else {
			set result ""
		}
		return $result
	}

	proc toMillis {seconds} {
		set s [string trim $seconds]
		set p [string first "." $s]
		if {$p < 0} {
			set result [expr $s * 1000]
		} else {
			set fractStr [string range $s [expr $p + 1] [string length $s]]
			set fractLength [string length $fractStr]
			if {$fractLength > 3} {
				set fractStr [string range $fractStr 0 2]
				set fractLength 3
			}
			set t 1
			append t $fractStr
			set millis [expr $t - [expr 10 ** $fractLength]]
			switch -exact -- $fractLength {
				1 {set factor 100}
				2 {
					if {$millis < 10} {
						set factor 10
					} else {
						set factor 100
					}
				}
				3 {
					set factor 1
				}
			}
			set millis [expr $millis * $factor]
			set result [expr [string range $s 0 [expr $p - 1]] * 1000 + $millis]
		}
		return $result
	}

	proc toTimeCode {ms} {
		if {$ms <= 0} {
			return "00:00:00.000"
		}
		variable MS_IN_SECOND
		variable MS_IN_MINUTE
		variable MS_IN_HOUR
		set t $ms;
		set hour [expr int($t / $MS_IN_HOUR)]
		set t [expr int(fmod($t, $MS_IN_HOUR))]
		set minute [expr int($t / $MS_IN_MINUTE)]
		set t [expr int(fmod($t, $MS_IN_MINUTE))]
		set second [expr int($t / $MS_IN_SECOND)]
		set millis [expr int(fmod($t, $MS_IN_SECOND))]
		return [format "%02d:%02d:%02d.%03d" $hour $minute $second $millis]
	}

	proc fromTimeCode {t} {
		set len [string length $t]
		if {$len != 12} {
			throw {NONE} "invalid timecode: $t"
		}
		set hour [toInt [string range $t 0 1]]
		set minute [toInt [string range $t 3 4]]
		set second [toInt [string range $t 6 7]]
		set millis [toInt [string range $t 9 [expr $len - 1]]]
		variable MS_IN_SECOND
		variable MS_IN_MINUTE
		variable MS_IN_HOUR
		return [expr $hour * $MS_IN_HOUR + $minute * $MS_IN_MINUTE + $second * $MS_IN_SECOND + $millis]
	}

	proc toInt {str} {
		if {[string length $str] == 0} {
			throw {NONE} {cannot convert empty string to int}
		}
		set result [string trimleft $str "0"]
		if {[string length $result] == 0} {
			set result 0
		}
		return $result
	}

	proc sleep {ms} {
		set stop_wait 1
		after $ms set stop_wait &
		vwait stop_wait
	}

	proc numOfFfprobeThreads {} {
		return [expr int($setting::numOfProcessors * 1.5)]
	}

	proc isNotValid {keyFrames} {
		set prev -1
		foreach f $keyFrames {
			if {$f <= $prev} {
				return 1
			}
			set prev $f
		}
		return 0
	}

	proc gcd {x y} {
		if {$y == 0} {
			return $x
		}
		return [gcd $y [expr int(fmod($x, $y))]]
	}
}
