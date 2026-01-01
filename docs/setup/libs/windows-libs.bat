@echo off
color 0a
cd /d %USERPROFILE%
@echo on
echo Installing Haxe-Libs dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.3.0
haxelib install openfl 9.5.0
haxelib install flixel 6.1.2
haxelib install flixel-tools 1.5.1
haxelib install flixel-addons 4.0.1
haxelib install hxdiscord_rpc 1.3.0
haxelib set lime 8.3.0
haxelib set openfl 9.5.0
echo Installed!
pause