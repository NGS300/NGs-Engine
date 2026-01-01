@echo off
cls
color 04
title Build Tool - v1.5 - Release (x86)

echo Welcome:
hostname
echo.

timeout /t 1 >nul
cd ..\..\..

color 0a
echo Building...
echo.
lime test windows -32 -release -D 32bits -D HXCPP_M32
echo.
echo done.

timeout /t 1 /nobreak >nul
pause