package;

import openfl.utils.AssetType;
import util.PathsUtil;
import flash.media.Sound;

/**
	** A Core class which handles determining asset paths.
 */
class Paths {
	inline public static function exists(path:String, ?type:AssetType):Bool
		return PathsUtil.existsAny(path, type ?? TEXT);

	public static function clearUnusedCache()
		PathsUtil.clearUnusedMemory();

	public static function clearMemoryCache()
		PathsUtil.clearStoredMemory();

	public static function getPath(file:String, ?folder:String, ?type:AssetType):String
		return PathsUtil.getPath(file, type ?? TEXT, folder);

	public static function font(key:String, ?folder:String, print = true):String
		return PathsUtil.font(key, folder, print);

	public static function text(key:String, ?folder:String, print = true):String
		return PathsUtil.data(key, folder, print);

	public static function txt(key:String, ?folder:String, print = true):String
		return PathsUtil.data(key, folder, print);
		//return PathsUtil.txt(key, folder, print);

	public static function json(key:String, ?folder:String, print = true):String
		return PathsUtil.data(key, folder, print);
		//return PathsUtil.json(key, folder, print);

	public static function sound(key:String, ?folder:String, print = true):Sound
		return PathsUtil.sound(key, folder, print);

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

	public static function textures(key:String, ?folder:String):Dynamic
		return PathsUtil.textures(key, folder);

	public static function video(key:String, ?folder:String, print = true):String
		return PathsUtil.videos(key, folder, print);
}