namespace eval size {
	namespace export newSize getWidth getHeight toString

	variable widthIndex "w"
	variable heightIndex "h"

	proc newSize {width height} {
		variable widthIndex
		variable heightIndex
		return [dict create $widthIndex $width $heightIndex $height]
	}

	proc getWidth {size} {
		variable widthIndex
		return [dict get $size $widthIndex]
	}

	proc getHeight {size} {
		variable heightIndex
		return [dict get $size $heightIndex]
	}

	proc toString {size} {
		return [format "%sx%s" [getWidth $size] [getHeight $size]]
	}
}
