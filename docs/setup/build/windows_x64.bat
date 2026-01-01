@echo off
cls
color 04
title Build Tool - v1.5 - Release (x64)

echo Welcome:
hostname
echo.

timeout /t 1 >nul
cd ..\..\..

color 0a
echo Building...
echo.
lime test windows -release
echo.
echo done.

timeout /t 1 /nobreak >nul
pause