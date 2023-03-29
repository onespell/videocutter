source json.tcl

namespace eval job {
	namespace export shotJobType clipJobType getJobType getFormat getTime getFinish getSize getVideo getAudio newShotJob newClipJob

	variable shotJobType "f"
	variable clipJobType "s"
	variable typeIndex "typ"
	variable formatIndex "fmt"
	variable timeIndex "t"
	variable finishIndex "e"
	variable sizeIndex "sz"
	variable videoIndex "v"
	variable audioIndex "a"

	proc newShotJob {millis format} {
		variable shotJobType
		variable typeIndex
		variable formatIndex
		variable timeIndex
		return [dict create $typeIndex $shotJobType $timeIndex $millis $formatIndex $format]
	}

	proc getJobType {job} {
		variable typeIndex
		return [dict get $job $typeIndex]
	}

	proc getFormat {job} {
		variable formatIndex
		return [dict get $job $formatIndex]
	}

	proc getTime {job} {
		variable timeIndex
		return [dict get $job $timeIndex]
	}

	proc newClipJob {start finish format size video audio} {
		variable clipJobType
		variable typeIndex
		variable formatIndex
		variable timeIndex
		variable finishIndex
		variable sizeIndex
		variable videoIndex
		variable audioIndex
		variable reencodeIndex
		return [dict create $typeIndex $clipJobType $timeIndex $start $finishIndex $finish $formatIndex $format $sizeIndex $size $videoIndex $video $audioIndex $audio]
	}

	proc getFinish {job} {
		variable finishIndex
		return [dict get $job $finishIndex]
	}

	proc getSize {job} {
		variable sizeIndex
		return [dict get $job $sizeIndex]
	}

	proc getVideo {job} {
		variable videoIndex
		return [dict get $job $videoIndex]
	}

	proc getAudio {job} {
		variable audioIndex
		return [dict get $job $audioIndex]
	}

}
