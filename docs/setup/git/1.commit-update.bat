@echo off
cls
color 04
title Github Commit - 1.1

echo Welcome:
hostname
echo.

timeout /t 1 >nul
cd ..\..\..

color 0a
echo Updating items...
echo.
git add *
echo git *
git commit -m "updated items"
echo.
echo done.

timeout /t 1 /nobreak >nul
pause