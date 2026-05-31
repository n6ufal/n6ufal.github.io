@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   Video Encoding Script
echo   Target: Optimize for web deployment
echo ============================================
echo.

cd /d "%~dp0"

set "source=static\videos\fakemink - Easter Pink (Prod Suzy Sheer).mkv"
set "mp4_output=static\videos\bg-video.mp4"
set "webm_output=static\videos\bg-video.webm"

if not exist "!source!" (
    echo ERROR: Source video not found: !source!
    pause
    exit /b 1
)

echo Source video: !source!
for %%A in ("!source!") do (
    set /a size=%%~zA
    echo File size: !size! bytes ^(~13 MB^)
)
echo.

REM Encode MP4 with lower bitrate target
echo [1/2] Encoding MP4 with H.265 at 1000 kb/s target...
echo.
ffmpeg -i "!source!" -c:v libx265 -b:v 1000k -c:a aac -b:a 128k "!mp4_output!"

if errorlevel 1 (
    echo ERROR: MP4 encoding failed
    pause
    exit /b 1
)

echo.
echo MP4 encoding complete!
for %%A in ("!mp4_output!") do (
    set /a size=%%~zA
    echo File size: !size! bytes
)
echo.

REM Encode WebM with lower bitrate target
echo [2/2] Encoding WebM with VP9 at 800 kb/s target...
echo.
ffmpeg -i "!source!" -c:v libvpx-vp9 -b:v 800k -c:a libopus -b:a 128k "!webm_output!"

if errorlevel 1 (
    echo ERROR: WebM encoding failed
    pause
    exit /b 1
)

echo.
echo WebM encoding complete!
for %%A in ("!webm_output!") do (
    set /a size=%%~zA
    echo File size: !size! bytes
)
echo.

echo ============================================
echo   Encoding Complete!
echo ============================================
echo.
echo Next steps:
echo   1. Test the video on your site locally with: hugo server
echo   2. Play the video and check for quality issues
echo   3. If quality is good:
echo      - Commit: git add -A ^&^& git commit -m "Optimize video files"
echo      - Push: git push
echo   4. If quality is not acceptable:
echo      - Delete both output files
echo      - Adjust bitrates and re-run
echo.
pause
