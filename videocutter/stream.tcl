namespace eval stream {
	namespace export newAudioStream newVideoStream getId getCaption setCaption

	variable audio "A"
	variable video "V"
	variable typeIndex "t"
	variable idIndex "i"
	variable captionIndex "c"

	proc newAudioStream {id caption} {
		variable audio
		variable typeIndex
		variable idIndex
		variable captionIndex
		return [dict create $typeIndex $audio $idIndex $id $captionIndex $caption]
	}

	proc newVideoStream {id caption} {
		variable video
		variable typeIndex
		variable idIndex
		variable captionIndex
		return [dict create $typeIndex $video $idIndex $id $captionIndex $caption]
	}

	proc getId {stream} {
		variable idIndex
		return [dict get $stream $idIndex]
	}

	proc getCaption {stream} {
		variable captionIndex
		return [dict get $stream $captionIndex]
	}

	proc setCaption {stream caption} {
		variable captionIndex
		[dict set $stream $captionIndex $caption]
	}
}
