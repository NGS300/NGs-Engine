package;

import openfl.Lib;
import util.WindowUtil;
import openfl.events.Event;
import openfl.display.Sprite;
import util.debug.FPSCounter;
import util.debug.MemoryCounter;

/**
 * The Main class which initializes HaxeFlixel and starts the game in its initial state.
 */
class Main extends Sprite {
	public static final os:PlatformInfo = WindowUtil.platform;
	static var ramUI:MemoryCounter;
	static var fpsUI:FPSCounter;
	
	function main()
		Lib.current.addChild(new Main());

	function new() {
		super();
		(stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init));
	}

	function init(?E:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);
		WindowUtil.init();
		var res = {
			gameW: 1280,
			gameH: 720,
		};
		#if (cpp && windows)
		objects.internal.Native.fix(res.gameW, res.gameH);
		#end

		flixel.FlxG.save.bind('funkin', util.SaveUtil.savePath());
		Controls.instance = new Controls();
		var game = new flixel.FlxGame(res.gameW, res.gameH, core.states.TitleState, 60, 60, true, false);
		@:privateAccess
		game._customSoundTray = objects.internal.SoundTray;
		addChild(game);

		if (os.isWindows || os.isLinux || os.isMac) {
			Lib.current.stage.align = "tl";
			Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		}
		Settings.load();
		Settings.save();
		util.debug.DiscordClient.start();

		if (os.isLinux || os.isMac) 
			Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("icon.png"));

		if (os.isHtml5) {
			FlxG.autoPause = false;
			FlxG.keys.preventDefaultKeys = [TAB];
		}

		FlxG.mouse.visible = false;
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;

		if (!os.isMobile) {
			var fps = Settings.game.showFPS;
			var ram = Settings.game.showRAM;
			fpsUI = new FPSCounter(!ram ? 2 : 14);
			fpsUI.visible = fps;
			addChild(fpsUI);
			ramUI = new MemoryCounter(2);
			ramUI.visible = (!fps ? false : ram);
			addChild(ramUI);
		}

		FlxG.signals.gameResized.add(function(w, h) {
			if (FlxG.cameras != null) {
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
			}
			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	public static function reloadUI() {
		if (!os.isMobile) {
			var fps = Settings.game.showFPS;
			var ram = Settings.game.showRAM;
			fpsUI.visible = fps;
			fpsUI.y = (!ram ? 2 : 14);
			ramUI.visible = (!fps ? false : ram);
		}
	}

	function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}