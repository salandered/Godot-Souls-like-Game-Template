@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem --- Process each immediate subfolder in the current directory ---
for /D %%A in (*) do (
	rem Skip if not a directory for any reason
	if exist "%%~fA\" (
		set /a files=0
		set /a subdirs=0
		set "onlysub="

		rem Count files at this level
		for /f "delims=" %%F in ('dir /b /a-d "%%~fA"') do (
			set /a files+=1
		)

		rem Count subfolders and remember the single one (if any)
		for /f "delims=" %%S in ('dir /b /ad "%%~fA"') do (
			set /a subdirs+=1
			set "onlysub=%%~fA\%%S"
		)

		rem Simplify only if: zero files AND exactly one subfolder
		if !files! EQU 0 if !subdirs! EQU 1 (
			echo [FLATTEN] %%~nxA -> !onlysub!
			rem Move files from the only subfolder up
			for %%I in ("!onlysub!\*") do (
				move /Y "%%~fI" "%%~fA\" >nul
			)
			rem Move subfolders from the only subfolder up
			for /D %%I in ("!onlysub!\*") do (
				move /Y "%%~fI" "%%~fA\" >nul
			)
			rem Remove the now-empty subfolder
			rd "!onlysub!" 2>nul
		) else (
			rem Not a simple [only one subfolder, no files] case; skip
			rem echo [SKIP] %%~nxA (files=!files!, subdirs=!subdirs!)
		)
	)
)

echo Done.
endlocal
