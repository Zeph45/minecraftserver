@echo off
title Minecraft Server - Roshar

:: Always make sure we're in the folder where this .bat file is located
cd /d "%~dp0"

echo.
echo =============================================
echo Pulling latest changes from GitHub...
echo =============================================

git pull origin main --ff-only 2>nul || (
    echo.
    echo WARNING: Pull skipped.
    echo   - Not a git repo yet? Run: git init + git remote add origin ...
    echo   - No internet? Check connection.
    echo   - Auth issue? Use Personal Access Token.
    echo Continuing anyway...
    timeout /t 4 >nul
)

echo.
echo =============================================
echo Starting Minecraft server...
echo =============================================

:: Adjust RAM and java path if needed
"C:\Program Files\Java\jdk-21\bin\java.exe" ^
    -Xms4G -Xmx6G ^
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled ^
    -XX:MaxGCPauseMillis=200 ^
    -jar Roshar.jar nogui

echo.
echo =============================================
echo Server has stopped.
echo Committing and pushing changes...
echo =============================================

:: Only add files we actually want to track
git add world/                              2>nul
git add .gitignore .gitattributes           2>nul
git add server.properties                   2>nul
git add ops.json whitelist.json             2>nul
git add banned-players.json banned-ips.json 2>nul

:: Commit only if there are staged changes
git commit -m "Backup - %DATE% %TIME%" >nul 2>&1 || (
    echo No meaningful changes to commit ^(logs/temp files are ignored^).
)

:: Push if there was a commit (or nothing happens)
git push origin main 2>nul || (
    echo Push skipped ^(no new commit / connection issue / auth needed^).
)

echo.
echo =============================================
echo Backup process finished.
echo =============================================

pause