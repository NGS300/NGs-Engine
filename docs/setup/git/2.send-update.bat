@echo off
cls
color 04
title Github Send - 1.1

echo Wellcome:
hostname
echo.

timeout /t 1 >nul
cd ..\..\..

if not exist .git (
  echo ERROR: Git repository not found.
  pause
  exit /b
)

color 0a
echo Sending items...
echo.
git push origin main
echo.
echo done.

timeout /t 1 /nobreak >nul
pause