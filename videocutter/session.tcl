namespace eval session {
	namespace export init setWorkingDir workingDir fileTypes volume setVolume filePath setFilePath

	variable workingDir
	variable fileTypes
	variable volume
	variable filePath

	proc init {defaultWorkingDir defaultFileTypes defaultVolume} {
		variable workingDir
		variable fileTypes
		variable volume
		set workingDir $defaultWorkingDir
		set fileTypes $defaultFileTypes
		set volume $defaultVolume
	}

	proc setWorkingDir {value} {
		variable workingDir
		set workingDir $value
	}

	proc setVolume {vol} {
		variable volume
		set volume $vol
	}

	proc setFilePath {value} {
		variable filePath
		set filePath $value
	}
}
