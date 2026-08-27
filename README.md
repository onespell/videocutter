# videocutter
This is an application for taking clips or frames from video file. It is written in Tcl/Tk and uses mplayer and ffmpeg under the hood.

## How to install
* Prerequisites: ffmpeg (https://ffmpeg.org), ffprobe (https://ffmpeg.org/ffprobe.html), MPlayer (http://www.mplayerhq.hu) or mpv (https://mpv.io), tcl 8.6, tk 8.6, tksvg (https://wiki.tcl-lang.org/page/tksvg), BWidget (https://wiki.tcl-lang.org/page/BWidget), tcllib (https://www.tcl.tk/software/tcllib/).
* Copy directory "videocutter" to any place on local file system.
* Correct file settings.tcl:
  * player - "mpv" or "mplayer" (mpv is more reliable, but it's available only on Unix-like systems)
  * imageTool - method to take snapshots, possible values: "ffmpeg", "mpv" or "cwebp" (use mpv to take snapshot and cwebp to convert it to webp format); "ffmpeg" is slowest
  * locale - interface language ("ru", "en")
  * numOfProcessors - processors number for the ffprobe and ffmpeg "-threads" option
  * ffprobePath - path to ffprobe
  * ffmpegPath - path to ffmpeg
  * mplayerPath - path to mplayer
  * logPath - path to log file
  * initialDir - directory to open file from the menu
  * ffmpegReport - "on" to use ffmpeg "-report" option
  * defaultVolume - volume level (0-100)
  * muteOnStart - "true" to mute on file opening
* To launch videocutter execute vc.tcl (or you can edit and use script vc.sh).

## How to use
* Launch application without arguments (or with a video file name as the argument).
* File → Open (Ctrl-O) to open a video.
* Navigating through the video, use tools on the right panel to create freeze-frame or clip jobs.
	* Use ![rewind](assets/rewind.png) and ![fast-forward](assets/forward.png) buttons to go to key frames.
	* Use ![refine-left](assets/previous.png) and ![refine-right](assets/next.png) buttons to refine frame search. The first press of one of these buttons sets the search interval from the current slider position to the nearest key frame; subsequent presses halve the interval. Eventually, the interval narrows to a single point or becomes so small that it's impossible to position the slider in its middle.
* Also you can manually import jobs from text lines (the same syntax as in the application log file).
* You can double-click a job to jump to the corresponding timestamp in video.
* To edit the job list, you can select and delete jobs pressing Delete.
* Press the "run" button to execute jobs. Images and clips will be created near the source file.
* At the end use menu File -> Quit (Ctrl-Q) to quit.

![vc](assets/vc.png)
* 1 - play/pause
* 2 - go to next/previous key frame (also you can use Up and Down for it)
* 3 - binary frame search (also you can use Left and Right for it)
* 4 - volume control
* 5 - mute/unmute
* 6 - take a frame
* 7 - take a clip
* 8 - input jobs manually (the same syntax as in log file)
* 9 - jobs list
* 10 - execute jobs (check "dry run" to just preview commands)

## Files
* vc.tcl - the main tcl script
* settings.tcl - application settings
* l10n/ - localization data
* svg/ - icons
