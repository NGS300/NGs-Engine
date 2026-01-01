package util;

import flash.media.Sound;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;
import flixel.graphics.frames.FlxAtlasFrames;

/**
 * Paths extension
 * Be careful, this is core paths; if you don't know what you're doing, you'll have problems.
 */
@:access(openfl.display.BitmapData)
class PathsUtil {
	public static final soundFile:String = #if web "mp3" #else "ogg" #end;
	static var currentLevel:Null<String> = null;
	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/shared/music/freakyMenu.$soundFile'];
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
				destroyGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
		// run the garbage collector for good measure lmfao
		openfl.system.System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	public static function clearStoredMemory() {
		for (key in FlxG.bitmap._cache.keys()) { // Clear anything not in the tracked assets list
			if (!currentTrackedAssets.exists(key))
				destroyGraphic(FlxG.bitmap.get(key));
		}
		for (key => asset in currentTrackedSounds) { // Clear all sounds that are cached
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && asset != null) {
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		// #if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	public static function freeGraphicsFromMemory() {
		var protectedGfx:Array<FlxGraphic> = [];
		function checkForGraphics(spr:Dynamic) {
			try {
				var grp:Array<Dynamic> = Reflect.getProperty(spr, 'members');
				if (grp != null) {
					for (member in grp) {
						checkForGraphics(member);
					}
					return;
				}
			}
			try {
				var gfx:FlxGraphic = Reflect.getProperty(spr, 'graphic');
				if (gfx != null) {
					protectedGfx.push(gfx);
				}
			}
		}

		for (member in FlxG.state.members)
			checkForGraphics(member);

		if (FlxG.state.subState != null)
			for (member in FlxG.state.subState.members)
				checkForGraphics(member);

		for (key in currentTrackedAssets.keys()) { // if it is not currently contained within the used local assets
			if (!dumpExclusions.contains(key)) {
				var graphic:FlxGraphic = currentTrackedAssets.get(key);
				if (!protectedGfx.contains(graphic)) {
					destroyGraphic(graphic); // get rid of the graphic
					currentTrackedAssets.remove(key); // and remove the key from local cache map
				}
			}
		}
	}

	inline static function destroyGraphic(graphic:FlxGraphic) { // Free some GPU Memory
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	public static function setCurrentLevel(name:String):Void
		currentLevel = name.toLowerCase();

	public static function getPath(file:String, ?type:openfl.utils.AssetType = TEXT, ?folder:String):String {
		if (folder != null)
			return getFolderPath(file, folder);
		if (currentLevel != null && currentLevel != 'shared') {
			var levelPath = getFolderPath(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}
		return 'assets/shared/$file';
	}

	inline static public function getFolderPath(file:String, folder = 'shared')
		return 'assets/$folder/$file';

	public static function font(key:String, ?folder:String, canPrint = true):String {
		var ext = ['ttf', 'otf'];
		var path = (type:Int) -> getPath('$key.' + ext[type], TEXT, folder ?? 'fonts');
		if (OpenFlAssets.exists(path(0)))
			return path(0);
		else if (OpenFlAssets.exists(path(1)))
			return path(1);
		else if (canPrint)
			Log.info('File not found: $path');
		return null;
	}

	public static function txt(key:String, ?folder:String, canPrint = true):String {
		var path = () -> getPath('data/$key.txt', TEXT, folder);
		if (OpenFlAssets.exists(path()))
			return path();
		else if (canPrint)
			Log.info('File not found: $path');
		return null;
	}

	public static function json(key:String, ?folder:String, canPrint = true):String {
		var path = () -> getPath('data/$key.json', TEXT, folder);
		if (OpenFlAssets.exists(path()))
			return path();
		else if (canPrint)
			Log.info('File not found: $path');
		return null;
	}

	public static function sound(key:String, ?folder:String, canPrint = true):Sound
		return cacheSound('sounds/$key', folder, canPrint);

	public static function music(key:String, ?folder:String, canPrint = true):Sound
		return cacheSound('music/$key', folder, canPrint);

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function cacheSound(key:String, ?folder:String, canPrint = true) {
		var path = getPath(key + '.$soundFile', SOUND, folder);
		if (!currentTrackedSounds.exists(path)) {
			if (OpenFlAssets.exists(path, SOUND))
				currentTrackedSounds.set(path, OpenFlAssets.getSound(path));
			else if (canPrint) {
				Log.info('Sound file not found: $path');
				return null;
			}
		}
		localTrackedAssets.push(path);
		return currentTrackedSounds.get(path);
	}

	public static function videos(key:String, ?folder:String, canPrint = true):String {
		var path = () -> getPath('videos/$key.mp4', BINARY, folder ?? 'videos');
		if (OpenFlAssets.exists(path()))
			return path();
		else if (canPrint)
			Log.info('Video file not found: $path');
		return null;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static public function image(key:String, ?folder:String):FlxGraphic {
		key = 'images/$key.png';
		var bitmap:BitmapData = null;
		if (currentTrackedAssets.exists(key)) {
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		return cacheBitmap(key, folder, bitmap);
	}

	public static function atlas(key:String, ?folder:String, canPrint = true):FlxAtlasFrames {
		var ext = ['xml', 'json', 'txt'];
		var path = (type:Int) -> getPath('images/$key.' + ext[type], TEXT, folder);
		if (OpenFlAssets.exists(path(0)))
			return FlxAtlasFrames.fromSparrow(image(key, folder), path(0));
		else if (OpenFlAssets.exists(path(1)))
			return FlxAtlasFrames.fromTexturePackerJson(image(key, folder), path(1));
		else if (OpenFlAssets.exists(path(2)))
			return FlxAtlasFrames.fromSpriteSheetPacker(image(key, folder), path(2));
		else if (canPrint)
			Log.info('File atlas not found: $path');
		return null;
	}

	public static function textures(key:String, ?folder:String):Dynamic {
		var ext = ['xml', 'json', 'txt'];
		var atlasFound = false;
		for (e in ext) {
			var path = getPath('images/$key.' + e, TEXT, folder);
			if (OpenFlAssets.exists(path)) {
				atlasFound = true;
				break;
			}
		}

		if (atlasFound) {
			var atl = atlas(key, folder, false);
			if (atl != null)
				return atl;
		}

		var img = image(key, folder);
		if (img != null)
			return img;

		Log.info('File atlas or image not found in: $key');
		return null;
	}

	public static function cacheBitmap(key:String, ?folder:String, ?bitmap:BitmapData):FlxGraphic {
		if (bitmap == null) {
			var file = getPath(key, IMAGE, folder);
			if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
			if (bitmap == null) {
				Log.info('Bitmap not found: $file | key: $key');
				return null;
			}
		}
		
		if (Settings.game.allowGPU && bitmap.image != null) {
			bitmap.lock();
			if (bitmap.__texture == null) {
				bitmap.image.premultiplied = true;
				bitmap.getTexture(FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}

		var graph = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}
}