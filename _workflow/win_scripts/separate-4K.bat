@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "DEST=4K-downscale"
if not exist "%DEST%\" mkdir "%DEST%"

for /D %%A in (*) do (
	rem skip the destination folder itself
	if /I not "%%~nxA"=="%DEST%" (
		set "name=%%~nxA"
		set "test=!name:4K=!"
		if /I not "!test!"=="!name!" (
			echo [MOVE] %%~nxA -> "%DEST%\"
			move "%%~fA" "%DEST%\" >nul
		)
	)
)

echo Done.
endlocal
