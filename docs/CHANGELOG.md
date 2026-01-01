## [0.0.3] 2026-01-01
***Engine stage: Pre-Production***

### Added
* I added an operating system checker that was #if..., which you can now use with a normal if statement. It might be useless for some? Maybe, but I love it. Just ignore it if you don't want to.

* CrashHander added.
* SongUtil was added, complicated stuff, huh? I think so too, depending on how it's used, maybe it will remove some things \o/
* added dateUtil, from the old engine

* Added SoundTry (v1 modification), I used the base of the original FlxSoundTry, but reworked it for my engine. It was smoothed for ups and downs; when it reaches off or max, the sound no longer plays. Also, when it's OFF, a bitdata is created to display a MUTE icon. Yes, it's a bitdata; it might not have a sprite, that will depend on whether I get eternal help. When it's max, a new, thinner, and higher volume bar appears—a simple indicator. Depending on the volume level, the volume bars will have a color to indicate how loud it is. The fonts for debug and normal build are different.

* I added the timing structure; it came from KE 1.6.2, so I haven't studied it in depth yet. That's a bad answer, right? Yes, I know, the most complicated part of this engine will be the note/rhythm system.

* I added the alphabet, of course it came from KE 1.6.2, with minor modifications.
* I added Events.hx; I have an idea to create events similar to those in Psych, but for now it's just an idea.

* Added Engine.json, what is it? Simply put, it's the engine setup that doesn't need to be done manually even if you don't compile, great for mods. Also, I'm thinking of building the check save structure from it; if I can get it to pull online and read data, it will come from there.

* Added Controls.hx, I literally copied it from psych.
* I added CoolUtil.hx but there's still nothing there.
* I added PathsUtil, what is it for? Basically, it's Paths but in its raw form, it's the raw code for Paths; I recommend not modifying it if necessary (PathsUtil will always be referenced to Paths.);

* Added memory cleaning by psych engine.
* Added DiscordClient, based somewhat on psych, it's a bit different for 2 reasons: 1. My hxdiscord version is different 2. I decided to change some things by choice.

* I added the BUILDING.md file to install the dependencies for this version.
* I added images to README.md and installation files to BUILDING.md.
* Added a fix for the "hxcpp-debug-server from v1.2.4", regarding the "decapitated" files that appeared in the compilation console. It's simply a choice whether you want that to appear or not. (It's optional)

- TitleState
  - Built from scratch, with unusual refactorings based on older builds, aided by KE 1.6.2 and Psych 1.0.
  - Based on the recent engine dropout, the gradients are now smoother and more animated, and so is the title text, which changes state after the title text (sprite) tween finishes.

  - Some irrelevant compression and modifications (I think).

- WarningState
  - Added WarningState, similar to Psych's FlashState, but with differences: 1. WarningState appears once per save, only reappearing if the save is deleted; 2. I added a small arrow below the choices; 3. I limited anti-spam and left and right paths only, no looping; 4. When selecting an option, there's a slight increase in size and decrease to look good; 5. The "^" arrow is also a bounce indicator, and when options are selected it turns yellow and vice versa; 6. The save for this state is used exclusively here, so it's not created in settings because it's not meant to be used.
  - Minor optimizations.

- MenuState
  - Add menus (these are the buttons) e.g. Story Mode..., in the left column, psych mouse support (modified), only bgDesat will be used and they are colored, magenta is the Flicker pressed is white not magenta anymore, yellowBG removed.
  - Fixed menus "X", both selected and idle.
  - Added fnfVer and engineVer.
  - The issue of pressing the up and down menu buttons simultaneously has been fixed.
  - added camFallow for bg

### Fixes
* Refactoring the source directories, I restructured them as best I could.
* WindowUtil has been improved and corrected, except for some irrelevant features.
* The logs have been redone with several corrections, mainly regarding output debugging and compatibility.

* Now, a topic about an idea I really liked, but it got extremely out of control. My old SaveData, KeyData, RawSave, and RawKeys were all removed, and I went back to using FlxG.save.data, which went through about 2-3 pre-tests. Why? Simple, I was thinking beyond what I could create because of the natural compatibility of Hashe. It didn't work; one became corrupted, the second kept returning null, and the third, I tried to fix the second, and it became corrupted. So I used the Psych save idea, because I was using the KE save idea but customized it, so I used the Psych idea and modified it as I wanted, and look, it worked! SaveUtil is the raw SaveEngine; I recommend not messing with it unless you need to do a custom init of a configuration, but the main place to use it is Settings, which is extended to SaveUtil. I also used the Psych idea and I created different save files [controls, data, Engine], it will also have a score, but for now it doesn't exist. Also, the main things for saving or creating saves are in the settings. As I said, it only opens the saveutil if you're going to put a custom value for your save/load. Settings also pulls pressed, justPressed, and justReleased, which are created in saveutil. As you can see in the title or other states, it works differently, especially when using strings. You might find it useless just because it's supposed to be used like this: `"FlxG.keys.justPressed.ENTER"`, but for me, I just need to put the key correctly like this: `"Settings.justPressed('ENTER')"`. And of course, my saves have undergone a sad, complicated, and extremely annoying reformulation.

* FPSCounter was also remade, based on my old idea. Things started breaking, so I decided to redo it. The original idea I changed was from Psych, but I kept making changes, mainly to the debug mode. The debug mode has more info for developers, plus it also has color options. The normal mode didn't change much besides the color, and I added a new font.
* MemoryCounter was also redone, I used psych as well, and I also added colors, the debugger has more information for the devs, and the name txt is not memory it's ram.

* I fixed Soundtry after I installed it, right? Idiot? Yes, it is, but why did it happen? Simple, I updated all my libraries, Soundtry broke 50% of what I did, which was "animations," not only that, rebuilding the code several times, how many? If when I created it, there were 1-2.hx files that were bad, to fix them there were 5-6.hx files, tsk, this crap; new thing, now there's a fadeout when you zoom out, there might be a visual bug, but that's it, I'm tired, that's what I got, comparing it after the break appeared is already too good.
* I fixed the window title, which previously only displayed the engine name; now it also includes "FNF".

* Seriously, I removed the smoothing from the bars and the max indicator and replaced the smoothing on the alpha and y of the update, I cleaned up the SoundTry again, but now it works without any annoying bugs.

* I fixed the "decapitated" error that was occurring on ChangeState.

### Changes
* I changed the folder from src to source, how stupid of me, right? Yeah, I think so too.
* WinUtil starts only once; the log starts inside the WinUtil init process, which then starts after WinUtil begins.

* Paths has been redesigned, I've also made some improvements.
* I updated the project.xml file, removed unnecessary things, redesigned some things, and fixed a few things.

* Paths has been updated by organizing and polishing the class. All Paths automatically locate the end of the file; for now, support is only for ASSETS, but system and mod support will be added in the future.

* a small change in import.hx
* I changed my stagecalc from main.hx to the native psych engine.
* import.hx was modified again because I saw something interesting in psych that I hadn't thought of, and it helps a lot by removing useless, repeated imports.

* I updated the README.md to the current version.
* I updated the CHANGELOG.md file to the current version, and I've improved its structure and organization.

* I updated the build files.
* I updated the .gitignore file.
* I updated the git.bash files.
* a general cleaning of the .hx files and polishing

- BeatState
  - Complete refactoring, and using the base from ke 1.6.2 for songs (step, beat, and state).
  - `change(func.)`, now it pulls the class correctly without needing to use `"new Classe()"` every time you need it, it's just `(Class)`.
  - I improved the clock system that pulls data from your PC, using the old engine.
  - Transitions are created/set, but outside of other classes you have to pull at least the transOut; (I'm thinking if I should try to make a function that pulls it).

- Conductor
  - He was created based on KE 1.6.2 and some ideas from Psych, but it has been refactored.
  - As you can see, it looks like a diff in a conductor, right? Don't even talk to me about it.

### Removed
* Several .hx files were redesigned, and the old ones were removed. Well, I don't remember which ones they were, but you can check for yourselves.

* CoreData and MainCore were removed. Why? Why have two with similar purposes? They were merged and became Core.hx.

* removed GF Title, Yellow menu, newgrounds logo

## [0.0.2] 2025-??-??
### __SKIPED__

## [0.0.1] 2025-0?-??
### __SKIPED__