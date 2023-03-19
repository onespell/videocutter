# videocutter
This is an application for taking clips or frames from video file. It is written in Tcl/Tk and uses mplayer and ffmpeg under the hood.

## How to install
* Prerequisites: ffmpeg (https://ffmpeg.org), ffprobe (https://ffmpeg.org/ffprobe.html), MPlayer (http://www.mplayerhq.hu), tcl 8.6, tk 8.6, tksvg (https://wiki.tcl-lang.org/page/tksvg), BWidget (https://wiki.tcl-lang.org/page/BWidget).
* Copy directory "videocutter" to any place on local file system.
* Correct file settings.tcl:
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
* Use menu File -> Open (Ctrl-O) to open video file.
* Navigating through the video, use tools on the right panel to create jobs.
* Also you can manually import jobs from text lines (the same syntax as in the application log file).
* You can double-click a job to jump to the corresponding timestamp in video.
* To edit the job list, you can select and delete jobs pressing Delete.
* Press the "run" button to execute jobs. Images and clips will be created near the source file.
* At the end use menu File -> Quit (Ctrl-Q) to quit.

![vc](https://user-images.githubusercontent.com/764089/226156443-a2a9e73f-037d-43c0-a8af-b0a20a6fcc2f.png)
* 1 - play/pause
* 2 - go to next/previous key frame (also you can use Up and Down for it)
* 3 - volume control
* 4 - mute/unmute
* 5 - take a frame
* 6 - take a clip
* 7 - input jobs manually (the same syntax as in log file)
* 8 - jobs list
* 9 - execute jobs (check "dry run" to just view corresponding ffmpeg commands)

## Files
* vc.tcl - the main tcl script
* settings.tcl - application settings
* l10n/ - localization data
* svg/ - icons
