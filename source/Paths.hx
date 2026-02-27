package;

import util.PathsUtil;
import flash.media.Sound;

/**
	** A Core class which handles determining asset paths.
 */
class Paths {
	public static function clearMemoryCache()
		PathsUtil.clearStoredMemory();
	public static function clearUnusedCache()
		PathsUtil.clearUnusedMemory();

	public static function getPath(file:String, ?folder:String, ?type:openfl.utils.AssetType):String
		return PathsUtil.getPath(file, folder, type ?? TEXT);

	public static function font(key:String, ?folder:String, print = true):String
		return PathsUtil.font(key, folder, print);

	public static function hxs(key:String, ?folder:String, ?isScript:Bool):String
		return PathsUtil.hscript(key, folder, isScript);

	public static function text(key:String, ?folder:String, print = true):String
		return PathsUtil.data(key, folder, print);

	public static function txt(key:String, ?folder:String, print = true):String
		return PathsUtil.data(key, folder, print);

	public static function json(key:String, ?folder:String):String
		return PathsUtil.json(key, folder);

	public static function sound(key:String, ?folder:String, print = true):Sound
		return PathsUtil.sound(key, folder, print);

	public static function soundRandom(key:String,  min:Int, max:Int, ?folder:String, print = true):Sound
		return sound(key + FlxG.random.int(min, max), folder);

	public static function music(key:String, ?folder:String, print = true):Sound
		return PathsUtil.music(key, folder, print);

	public static function inst(key:String, print = true):Sound
		return PathsUtil.inst(key, print);

	public static function voices(key:String, ?postfix:String, print = true):Sound
		return PathsUtil.voices(key, postfix, print);

	public static function image(key:String, ?folder:String):flixel.graphics.FlxGraphic
		return PathsUtil.image(key, folder);

	public static function atlas(key:String, ?folder:String, canPrint = true):flixel.graphics.frames.FlxAtlasFrames
		return PathsUtil.atlas(key, folder, canPrint);

	public static function video(key:String, ?folder:String, print = true):String
		return PathsUtil.videos(key, folder, print);
}