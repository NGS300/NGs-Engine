package util;

import sys.FileSystem;
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
		#if !html5 openfl.Assets.cache.clear("songs"); #end
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

	inline public static function existsAny(path:String, ?type:openfl.utils.AssetType):Bool {
		#if sys
		if (FileSystem.exists(path))
			return true;
		#end
		return OpenFlAssets.exists(path, type);
	}

	public static function getPath(file:String, ?type:openfl.utils.AssetType = TEXT, ?folder:String):String {
		var dir = (folder != null && folder.trim() != '') ? folder : (currentLevel != null
			&& currentLevel.trim() != '' ? currentLevel : 'shared');

		if (dir != 'shared') {
			var path = 'assets/$dir/$file';
			if (existsAny(path, type))
				return path;
		}

		return 'assets/shared/$file';
	}

	inline static public function formatPath(path:String) {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;
		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	public static function font(key:String, ?folder:String, canPrint = true):String {
		for (ext in ['ttf', 'otf']) {
			final path = getPath('$key.$ext', TEXT, folder ?? 'fonts');
			if (existsAny(path, TEXT))
				return path;
		}

		if (canPrint)
			Log.info('File not found: ' + key);

		return null;
	}

	public static function data(key:String, ?folder:String, canPrint = true):String {
		for (ext in ['json', 'txt']) {
			final path = getPath('data/$key.$ext', TEXT, folder);
			if (existsAny(path, TEXT))
				return path;
		}

		if (canPrint)
			Log.info('File not found: ' + key);

		return null;
	}

	public static function sound(key:String, ?folder:String, canPrint = true):Sound
		return cacheSound('sounds/$key', folder, canPrint);

	public static function music(key:String, ?folder:String, canPrint = true):Sound
		return cacheSound('music/$key', folder, canPrint);

	inline static public function inst(song:String, canPrint = true):Sound
		return cacheSound(SongUtil.normalizePathName(song) + '/Inst', 'songs', true);

	inline static public function voices(song:String, ?postfix:String, canPrint = true):Sound {
		var songKey = SongUtil.normalizePathName(song) + '/Voices';
		if (postfix != null)
			songKey += '-' + postfix;
		return cacheSound(songKey, 'songs', true);
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function cacheSound(key:String, ?folder:String, canPrint = true) {
		final path = getPath('$key.$soundFile', SOUND, folder);
		if (!currentTrackedSounds.exists(path)) {
			#if sys
			if (FileSystem.exists(path))
				currentTrackedSounds.set(path, Sound.fromFile(path));
			#else
			if (OpenFlAssets.exists(path, SOUND))
				currentTrackedSounds.set(path, OpenFlAssets.getSound(path));
			#end
			else if (canPrint)
			Log.info('Sound file not found: ' + key); 
		}

		localTrackedAssets.push(path);
		return currentTrackedSounds.get(path);
	}

	public static function videos(key:String, ?folder:String, canPrint = true):String {
		final path = getPath('videos/$key.mp4', BINARY, folder ?? 'videos');
		if (existsAny(path, BINARY))
			return path;

		if (canPrint)
			Log.info('Video file not found: ' + key);

		return null;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static public function image(key:String, ?folder:String):FlxGraphic {
		key = 'images/$key.png';
		final cached = currentTrackedAssets.get(key);
		if (cached != null) {
			localTrackedAssets.push(key);
			return cached;
		}
		return cacheBitmap(key, folder);
	}

	public static function atlas(key:String, ?folder:String, canPrint = true):FlxAtlasFrames {
		final img = image(key, folder);
		for (ext in ['json', 'txt', 'xml']) {
			final path = getPath('images/$key.$ext', TEXT, folder);
			if (!existsAny(path, TEXT))
				continue;

			return switch (ext) {
				case 'json': FlxAtlasFrames.fromTexturePackerJson(img, path);
				case 'txt': FlxAtlasFrames.fromSpriteSheetPacker(img, path);
				case 'xml': FlxAtlasFrames.fromSparrow(img, path);
				default: null;
			}
		}
		if (canPrint)
			Log.info('File atlas not found: ' + key);

		return null;
	}

	public static function textures(key:String, ?folder:String):Dynamic {
		for (ext in ['json', 'txt', 'xml']) {
			if (existsAny(getPath('images/$key.$ext', TEXT, folder), TEXT)) {
				final atl = atlas(key, folder, false);
				if (atl != null)
					return atl;
				break;
			}
		}

		final img = image(key, folder);
		if (img != null)
			return img;

		Log.info('File atlas or image not found in: ' + key);
		return null;
	}

	public static function cacheBitmap(key:String, ?folder:String, ?bitmap:BitmapData):FlxGraphic {
		if (bitmap == null) {
			final file = getPath(key, IMAGE, folder);
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else if (OpenFlAssets.exists(file, IMAGE))
				bitmap = OpenFlAssets.getBitmapData(file);
			if (bitmap == null) {
				Log.info('Bitmap not found: ' + file + ' | key: ' + key);
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
			bitmap.image = null;
			bitmap.readable = true;
		}

		final graph = FlxGraphic.fromBitmapData(bitmap, false, key);
		graph.persist = true;
		graph.destroyOnNoUse = false;
		currentTrackedAssets.set(key, graph);
		localTrackedAssets.push(key);
		return graph;
	}
}