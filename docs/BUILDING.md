# NG's Engine Build Instructions [Pre-Production]

* [Dependencies](#dependencies)
* [Building](#building)

---

# Dependencies

- `git`
- (Windows only) Microsoft Visual Studio Community 2022
- Haxe (4.3.7 or perhaps higher?)

---

### Windows

For `git`, you're gonna want [git-scm](https://git-scm.com/downloads), download their binary executable there

For Haxe, you can get it from [the Haxe website](https://haxe.org/download/)

---

**(Next step is Windows only)**

After installing `git`, open a command prompt window and enter the following:

#### For Windows 10/11
```batch
vs_Community.exe --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --includeRecommended -p
```

#### For Windows 11 Only

- Change this:
```batch
--add Microsoft.VisualStudio.Component.Windows10SDK.19041
```

- For that:
```batch
--add Microsoft.VisualStudio.Component.Windows11SDK.22621
```

This will use `curl`, which is a tool for downloading certain files through your command prompt,
to download the binary for Microsoft Visual Studio with the specific packages you need for compiling on Windows.

(If you wish to not do this manually, go to the `docs/setup/libs` folder located in the root directory of this repository, and run `msvc-windows10.bat` or `msvc-windows11.bat`)

---

# Building

Head into the `docs/setup/libs` folder located in the root directory of this repository, and execute the setup file.

Open a standard Windows terminal or command prompt window without a custom directory.

If you're compiling for debugging, put this in the command prompt. `haxelib install hxcpp-debug-server 1.2.4`

For those who want the "deprecated" message to stop appearing, in `docs/setup/libs` there is `hxcpp_debug-fix.exe`, it will replace the .hx files that are marked as "deprecated" to fix the problem. (This is optional and only for those who will use `haxelib install hxcpp-debug-server 1.2.4` only)

### "Which setup file?"

It depends on your operating system. For Windows, run `windows-libs.bat`.

Please wait for haxelib to install. The process will be complete when you see the word "**Installed!**"

To build the game, run `lime test windows -release` Or open it in `docs/setup/build` and run `windows_x64.bat` or `windows_x32`.

---

### "It's taking a while, should I be worried?"

No, that's completely normal. When you compile HaxeFlixel games for the first time, it usually takes 5 to 10 minutes. This depends on the power of your hardware; depending on your PC, it's advisable not to open anything until it's compiled, as some may experience problems opening things or even freeze. It's better to have what you need open before starting to build and distract yourself while it runs. (The first time is always hard.)

### "I have an error saying ApplicationMain.exe : fatal error LNK1120: 1 unresolved externals!"

Run `lime test release -clean` again, or delete the export folder and recompile to check if the libraries/dependencies have been installed correctly.

---