namespace eval setting {
	namespace export locale numOfProcessors initialDir logPath mplayerPath ffprobePath ffmpegPath fileTypes imageFormats videoFormats defaultVolume muteOnStart aspectRatios ffmpegReport setFfmpegReport

	variable locale en # en ru
	variable numOfProcessors 16
	variable initialDir "/home/onespell/Downloads"
	variable logPath "/tmp/vc.log"
	variable mplayerPath "/usr/bin/mplayer"
	variable ffprobePath "/usr/bin/ffprobe"
	variable ffmpegPath "/usr/bin/ffmpeg"
	variable ffmpegReport off
	variable fileTypes {
		{all {*}}
		{avi {.avi}}
		{mkv {.mkv}}
		{mp4 {.mp4}}
		{mpeg {.mpg}}
	}
	variable imageFormats [list WEBP JPEG PNG]
	variable videoFormats [list MP4 AVI MKV WMV]
	variable defaultVolume 10
	variable muteOnStart true
	variable aspectRatios [dict create "16:9" [list [size::newSize 8192 4608] [size::newSize 7680 4320] [size::newSize 5120 2880] [size::newSize 3840 2160] [size::newSize 3200 1800] [size::newSize 3072 1728] [size::newSize 2880 1620] [size::newSize 2560 1440] [size::newSize 1920 1080] [size::newSize 1600 900] [size::newSize 1280 720] [size::newSize 640 360]] "4:3" [list [size::newSize 6144 4608] [size::newSize 4096 3072] [size::newSize 3840 2880] [size::newSize 3072 2304] [size::newSize 2880 2160] [size::newSize 2304 1728] [size::newSize 2160 1620] [size::newSize 1440 1080] [size::newSize 1280 960] [size::newSize 1024 768] [size::newSize 960 720]] "3:2" [list [size::newSize 1080 720]] "1:1" [list [size::newSize 1080 1080] [size::newSize 720 720]] "19:10" [list [size::newSize 4096 2160] [size::newSize 2048 1080] [size::newSize 1024 540]] "16:10" [list [size::newSize 1280 800] [size::newSize 1152 720] [size::newSize 576 360]] "235:100" [list [size::newSize 5120 2178] [size::newSize 4096 1642] [size::newSize 3840 1634] [size::newSize 2880 1226] [size::newSize 2048 870] [size::newSize 1920 816] [size::newSize 1280 544]] "239:100" [list [size::newSize 4096 1716] [size::newSize 2048 858] [size::newSize 1280 536]]]

	proc setFfmpegReport {value} {
		variable ffmpegReport
		set ffmpegReport $value
	}
}
