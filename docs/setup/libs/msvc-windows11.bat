@echo off
color 0a
cd /d "%USERPROFILE%\Downloads"
@echo on
echo Installing Microsoft Visual Studio Community (Dependency) (Win10)
vs_Community.exe ^
 --add Microsoft.VisualStudio.Workload.VCTools ^
 --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 ^
 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 ^
 --includeRecommended ^
 -p
echo Installed.
pause