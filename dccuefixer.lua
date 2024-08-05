--[[
DCCueFixer
Copyright (C) 2024 Indiscipline (elephanttalk+git [at} protonmail <dot> com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

local EXT_PRIO = { "flac", "wv", "ape", "alac", "wav" }
local FROM_DC
if type(DC) == 'table' and Dialogs then
	FROM_DC = true
else
	FROM_DC = false
end

function trimQuotes(str)
  local trimmed = str:match("^\"(.*)\"$")
  return trimmed or str
end

function err(message)
	if FROM_DC then
		Dialogs.MessageBox(message, "Error", 0)
	else
		io.stderr:write(message)
	end
end

function searchAudioByBaseName(baseName, dir, extensions)
	-- Get the list of files in the current directory
	local cmd = ""
	if package.config:sub(1,1) == "\\" then
	-- TODO: FIXME do not use ls/dir!
		cmd = string.format("dir /B /A-D \"%s\"", dir)
  else
		cmd = string.format("ls -1A -- '%s'", dir)
  end
	
	local filesS = io.popen(cmd)
  if not filesS then
		err("Error getting list of files")
		return
	end
	local filesStr = filesS:read("*all")
	-- Parse file list and build base name -> extensions map
	local files = {}
	for file in filesStr:gmatch("[^\r\n]+") do
		local baseName, ext = file:match("^(.+)%.(.+)$")
		if baseName and ext then
			files[baseName] = files[baseName] or {}
			table.insert(files[baseName], ext)
		end
	end
	-- Search in the table for a matching basename
	local extsFound = files[baseName]
	if extsFound then
		for _, ext in ipairs(extensions) do
			local cmp = ext:lower()
			for _, fileExt in ipairs(extsFound) do
				if fileExt:lower() == cmp then
					return baseName, fileExt -- Return the original extension
				end
			end
		end
	end
	return nil, nil
end

function replaceFilenameInCUE(cueText, dir)
	local lines = {}
	local targetBase, targetExt
	for line in string.gmatch(cueText .. "\n", "([^\n]*)\n") do --"[^\r\n]+"
		local pre, fname, post = line:match('^(FILE%s+)(.-)(%s+WAVE.-)$')
		if pre and post then
			fname = trimQuotes(fname)
			-- Extract base name from CUE filename
			local basename, _ = fname:match("^(.+)%.(.+)$")
			-- Find matching audio file and extension
			targetBase, targetExt = searchAudioByBaseName(basename, dir, EXT_PRIO)
			--err(string.format("'%s' '%s'", targetBase, targetExt))
			if targetBase then
				line = string.format('%s"%s.%s"%s', pre, targetBase, targetExt, post)
			end
		end
		table.insert(lines, line)
	end
	if targetExt then
		targetExt = targetExt:lower()
	else
		targetExt = ""
	end
	return table.concat(lines, '\n'), targetExt
end


local params = {...}
local path, inputFile, _ = params[1]:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
local input = io.open(params[1], "r")
if input then
	local cueText = input:read("*a")
	input:close()
	local newCue, targetExt = replaceFilenameInCUE(cueText, path)
	local cueBaseName, _ = inputFile:match("^(.+)%.(.+)$")
	local newCuePath = path .. cueBaseName .. "." .. targetExt .. ".cue" 
	local outputFD = io.open(newCuePath, "w")
	if outputFD then 
		outputFD:write(newCue)
		io.close(outputFD) 
	else
		err(string.format("Could not open '%s' for writing\n", newCuePath))
	end
else
	err("Could not open the input file")
end

