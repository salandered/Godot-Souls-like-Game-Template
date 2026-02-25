@echo off
echo ========================================
echo  Audio Converter for Godot
echo  Converting to 44.1kHz 16-bit WAV
echo ========================================
echo.

setlocal enabledelayedexpansion
set count=0

REM Convert all common audio formats
for %%f in (*.mp3 *.ogg *.flac *.m4a *.aac *.wma *.opus *.wav) do (
    echo Converting: %%f
    ffmpeg -i "%%f" -ar 44100 -sample_fmt s16 -y "%%~nf_converted.wav" 2>nul
    
    if !errorlevel! equ 0 (
        echo    [OK] Created: %%~nf_converted.wav
        set /a count+=1
    ) else (
        echo    [FAILED] Could not convert %%f
    )
    echo.
)

echo ========================================
echo Conversion complete!
echo Total files converted: %count%
echo ========================================
echo.
pause