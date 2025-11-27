@echo off
setlocal enabledelayedexpansion

set "logfile=downscale_log.txt"
set "output_dir=DOWNSCALED"

echo Starting downscale process: %date% %time% > "%logfile%"
echo [DEBUG] Starting texture downscaling process...
echo [DEBUG] Log file: %logfile%
echo [DEBUG] Output directory: %output_dir%

set /a counter=0
set /a folder_count=0

if not exist "%output_dir%" (
    echo [DEBUG] Creating output directory: %output_dir%
    mkdir "%output_dir%"
) else (
    echo [DEBUG] Output directory already exists: %output_dir%
)

for /d %%F in (*) do (
    if /i not "%%F"=="%output_dir%" (
        set /a folder_count+=1
        echo [DEBUG] Processing folder: %%F
        
        rem Handle folder name replacements
        set "folder_name=%%F"
        set "folder_name=!folder_name:4K=4d1K!"
        set "folder_name=!folder_name:4k=4d1K!"
        set "folder_name=!folder_name:2K=2d1K!"
        set "folder_name=!folder_name:2k=2d1K!"
        
        set "target_dir=%output_dir%\!folder_name!"
        
        if not exist "!target_dir!" (
            echo [DEBUG] Creating target directory: !target_dir!
            mkdir "!target_dir!"
        ) else (
            echo [DEBUG] Target directory already exists: !target_dir!
        )
        
        for %%I in ("%%F"\*.jpg "%%F"\*.png "%%F"\*.tif "%%F"\*.jpeg "%%F"\*.tiff "%%F"\*.bmp "%%F"\*.exr) do (
            if exist "%%I" (
                set "filename=%%~nI"
                set "extension=%%~xI"
                set "new_name=!filename!!extension!"
                
                rem Handle filename replacements
                set "new_name=!new_name:4K=4d1K!"
                set "new_name=!new_name:4k=4d1K!"
                set "new_name=!new_name:2K=2d1K!"
                set "new_name=!new_name:2k=2d1K!"
                
                echo [DEBUG] Processing: %%F\%%~nxI
                echo [DEBUG]   Output name: !new_name!
                
                rem Use ImageMagick to resize the image
                magick "%%I" -resize 25%% "!target_dir!\!new_name!"
                if !errorlevel! equ 0 (
                    echo Processed: %%F\%%~nxI -^> !target_dir!\!new_name! >> "%logfile%"
                    echo [DEBUG]   Successfully processed
                    set /a counter+=1
                ) else (
                    echo Failed to process: %%F\%%~nxI >> "%logfile%"
                    echo [ERROR]   Failed to process: %%F\%%~nxI
                )
            )
        )
    )
)

echo Total files processed: !counter! >> "%logfile%"
echo [DEBUG] #############################################
echo [DEBUG] PROCESSING COMPLETE
echo [DEBUG] Folders scanned: !folder_count!
echo [DEBUG] Files processed: !counter!
echo [DEBUG] #############################################

rem Keep the window open to see the results
echo.
echo Press any key to exit...
pause >nul

endlocal