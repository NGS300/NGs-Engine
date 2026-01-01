@echo off
cls
color 04
title Github Pull - 1.1

echo Wellcome:
hostname
echo.

timeout /t 1 >nul
cd ..\..\..

color 0a
echo Downloading items...
echo.
git pull origin main
echo.
echo done.

timeout /t 1 /nobreak >nul
pause