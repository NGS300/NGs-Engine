package util;

class WindowUtil {
	public static function init():Void {
		initPlatform(); // Platform var's Init
		var path = "engine.json";
		if (!sys.FileSystem.exists(path)) {
			Log.info('File $path Not exist!');
			return;
		}
		var data:Dynamic = haxe.Json.parse(sys.io.File.getContent(path));

		// --- Game ---
		var game = data.game;
		if (game != null) {
			Core.game.set('name', game.Name);
			Core.game.set('version', 'v' + game.Version);
		}

		// --- Engine ---
		var engine = data.engine;
		if (engine != null) {
			Core.engine.set('title', game.Name + ": " + engine.Engine /*+ " - " + engine.App*/);
			Core.engine.set('engine', engine.Engine);
			Core.engine.set('name', engine.App);
			Core.engine.set('version', 'v' + engine.Version);
			Core.engine.set('state', engine.State);
			Core.engine.set('number', engine.Number);
			Core.engine.set('date', engine.Date);
		}

		// --- API ---
		var api = data.api;
		if (api != null) {
			Core.api.set('discord_id', api.Discord);
			Core.api.set('jolt_key', api.GameJolt_Key);
			Core.api.set('jolt_id', api.GameJolt_ID);
		}

		// Handler de Error's
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, util.debug.CrashHandler.onCrash);
		lime.app.Application.current.window.title = Core.engine.get('title');
	}

	public static var platform:PlatformInfo = {
		isDebug: false,
		isNative: false,
		isWindows: false,
		isLinux: false,
		isMac: false,
		isHtml5: false,
		isMobile: false,
		isSwitch: false,
		isConsole: false
	};
    static function initPlatform():Void {
		// Debug
		platform.isDebug = #if debug true #else false #end;

		// Desktop
		platform.isNative = #if sys true #else false #end;
		platform.isWindows = #if windows true #else false #end;
		platform.isLinux = #if linux true #else false #end;
		platform.isMac = #if mac true #else false #end;

		// Web
		platform.isHtml5 = #if html5 true #else false #end;

		// Mobile
		platform.isMobile = #if (android || ios) true #else false #end;

		// Console
		platform.isSwitch = #if switch true #else false #end;
		platform.isConsole = #if (switch || ps4 || ps5 || xboxone || xsx) true #else false #end;
		Log.init();
    }
}

/**
 * Platform Info #if
 */
typedef PlatformInfo = {
	var isDebug:Bool;
	var isNative:Bool;
	var isWindows:Bool;
	var isLinux:Bool;
	var isMac:Bool;
	var isMobile:Bool;
	var isHtml5:Bool;
	var isSwitch:Bool;
	var isConsole:Bool;
}