@echo off
title Minecraft Server - Roshar

:: =============================================
:: Make sure we're in the correct folder (where this .bat file lives)
cd /d "%~dp0"

echo.
echo =============================================
echo Pulling latest changes from GitHub...
echo =============================================

:: Try to pull — will fail gracefully if not a git repo yet
git pull origin main --ff-only 2>nul || (
    echo.
    echo WARNING: Could not pull from GitHub.
    echo Possible reasons:
    echo   - This folder is not a Git repository yet
    echo   - No internet connection
    echo   - Remote not set up (origin)
    echo.
    echo To fix: Run these commands once in this folder:
    echo   git init
    echo   git remote add origin https://github.com/Zeph45/minecraftmundo
    echo   git add .
    echo   git commit -m "Initial backup"
    echo   git branch -M main
    echo   git push -u origin main
    echo.
    echo Continuing to start server anyway...
    timeout /t 5 >nul
)

echo.
echo =============================================
echo Starting Minecraft server...
echo =============================================

:: Launch the server (adjust path & RAM as needed)
"C:\Program Files\Java\jdk-21\bin\java.exe" -Xms4G -Xmx6G -jar Roshar.jar nogui

echo.
echo =============================================
echo Server has stopped.
echo Committing and pushing changes...
echo =============================================

:: Only stage important/changed files (mostly world)
git add world/                              2>nul
git add ops.json whitelist.json             2>nul
git add banned-players.json banned-ips.json 2>nul
git add server.properties                   2>nul   :: remove this line if you DON'T want to track settings

:: Commit only if there is something to commit
git commit -m "Auto backup - %DATE% %TIME%" || (
    echo No changes detected - skipping commit.
)

:: Push to GitHub
git push origin main 2>nul || (
    echo Push failed! (Check internet, authentication, or if remote is set up correctly)
)

echo.
echo =============================================
echo Backup process finished.
echo =============================================

pause