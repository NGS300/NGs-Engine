package util;

import sys.FileSystem;
import haxe.io.Path;
import haxe.DynamicAccess;
import haxe.Json;
import sys.io.File;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class LanguageManager {
	private static var rawData:DynamicAccess<Dynamic> = new DynamicAccess<Dynamic>();
	private static var languageStrings:Map<String, String> = new Map<String, String>();

	private static function isPlainObject(v:Dynamic):Bool {
		return v != null && Reflect.isObject(v) && !Std.isOfType(v, String) && !Std.isOfType(v, Array) && !Std.isOfType(v, Int) && !Std.isOfType(v, Float)
			&& !Std.isOfType(v, Bool);
	}

	private static function getData(obj:DynamicAccess<Dynamic>, out:Map<String, String>):Void {
		for (key in obj.keys())
			if (isPlainObject(obj.get(key)))
				getData(obj.get(key), out);
			else
				out.set(key, Std.string(obj.get(key)));
	}

	private static function getByPath(root:Dynamic, key:String):Dynamic {
		var current:Dynamic = root;

		for (p in key.split(".")) {
			if (current == null)
				return null;

			if (Reflect.isObject(current) && !Std.isOfType(current, Array)) {
				current = Reflect.field(current, p);
			} else {
				return null;
			}
		}

		return current;
	}

	public static function loadFile(path:String):Void {
		if (FileSystem.exists(path))
			Log.info('Language file loaded with sucess');

		var data:String = OpenFlAssets.getText(path);

		for (key => value in languageStrings)
			languageStrings.remove(key);

		rawData = Json.parse(data);

		getData(rawData, languageStrings);
	}

	public static function getRaw(path:String):Null<Dynamic> {
		return getByPath(rawData, path);
	}

	public static function get(key:String):Null<String> {
		if (languageStrings.exists(key))
			return languageStrings.get(key);
		return null;
	}
}
