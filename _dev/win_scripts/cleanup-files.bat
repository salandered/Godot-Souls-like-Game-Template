@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "LOGFILE=%~dp0deleted_files_log.txt"
echo Cleanup started on %date% %time% > "%LOGFILE%"

echo Deleting NormalDX, Displacement/Disp/Height, USD(A/C), and PREVIEW files...
for /R %%F in (*NormalDX* *Displacement* *Disp* *Height* *PREVIEW* *.usda *.usdc) do (
	if exist "%%F" if not exist "%%F\" (
		echo [DEL] %%F
		del /Q "%%F"
		echo %%F >> "%LOGFILE%"
	)
)

echo Done. Deleted files are listed in %LOGFILE%.
endlocal
