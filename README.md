## DCCueFixer

### Use case

DCCueFixer is a Lua script that automatically corrects a common mismatch between a file name linked in a CUE sheet and the actual audio file found in the same directory.

DCCueFixer specifically addresses an irritatingly frequent case happening with a *particular* way lossless music is distributed, where the CUE file is generated before compressing the WAV file with some lossless codec. This results in an unlinked CUE (*arrr!!*), which prevents playback requiring fixing the CUE file manually.

This script supports both the standalone mode with a lua interpreter and being invoked with [DoubleCommander's lua scripting](https://doublecmd.github.io/doc/en/lua.html) feature.

### Usage

Both \*nix/Windows OS are supported. Lua interpreter (version 5.1 or later) or a DoubleCommander with Lua is required.

* From a terminal or command prompt:

  ```
  lua dccuefixer.lua <cue_file_name.cue>
  ```
  
  Replace `<cue_file_name.cue>` with the actual filename of your CUE sheet. 

* From DoubleCommander:
	1. Create a new toolbar button of the `Internal command` type.
	2. Select the `cm_ExecuteScipt` in the `Command:` drop-down menu.
	3. Fill the `Parameters:` textbox:
	
		```
		<full path to dcccuefixer.lua>
		%"0%p
		```
		
		This will run the script on the currently selected file in the active panel.

DCCueFixer scans the CUE file and writes a corrected one within the same directory as the original, adding the audio-file's extension to the CUE filename.

### Notes

- DCCueFixer prioritizes the following audio file extensions in its filename matching: FLAC, WV, APE, ALAC, WAV.
- If a CUE file entry cannot be matched, DCCueFixer leaves the filename unchanged.
- DCCueFixer outputs messages and errors via standard output in a command line environment, or via DoubleCommander’s message boxes when launched through it.
- The script assumes a basic CUE sheet structure and may not handle all variations.


### License

This project is licensed under the GNU General Public License v3.0 or later. See the LICENSE file for details.
