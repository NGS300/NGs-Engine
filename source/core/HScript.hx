package core;

import flixel.group.FlxGroup;
import objects.BGAnim;
import flixel.FlxObject;
import objects.BGSprite;
import flixel.FlxBasic;
import hscript.Parser;
import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

class HScript {
	public var interp(default, null):Interp;
	public var path(default, null):String;
	var canObjects:Bool = true;
	var loaded:Bool = false;
	var parser:Parser;

	public function new(name:String, ?setObj:Bool) {
		canObjects = setObj ?? true;
		path = name;
		load();
	}

	public function reload():Void {
		loaded = false;
		load();
	}

	public function load():Void {
		if (!FileSystem.exists(path)) {
			trace('HScript: Arquivo não encontrado -> ' + path);
			return;
		}

		parser = new Parser();
		interp = new Interp();
		try {
			var content = File.getContent(path);
			var program = parser.parseString(content);
			interp.execute(program);
			loaded = true;
			set("instance", this);
			set("FlxG", FlxG);
			set("Std", Std);
			set("Math", Math);
			set("Paths", Paths);
			set("Reflect", Reflect);
			set("Settings", Settings);
			set("Type", Type);
			set("StringTools", StringTools);

			set("randomInt", function(min:Int, max:Int) {
				return FlxG.random.int(min, max);
			});

			set("randomFloat", function(min:Float, max:Float) {
				return FlxG.random.float(min, max);
			});
			
			set("FlxTween", FlxTween);
			set("FlxEase", FlxEase);
			set("FlxTimer", FlxTimer);
			if (canObjects) {
				set("Character", Character);
				set("BGSprite", BGSprite);
				set("BGAnim", BGAnim);
				set("FlxSprite", FlxSprite);
				set("FlxGroup", FlxGroup);
				set('FlxSound', FlxSound);

				set("add", function(obj:FlxBasic) {
					return FlxG.state.add(obj);
				});

				set("remove", function(obj:FlxBasic) {
					return FlxG.state.remove(obj);
				});

				set("tween", function(obj:Dynamic, values:Dynamic, duration:Float, ?ease) {
					return FlxTween.tween(obj, values, duration, {ease: ease});
				});

				set("destroy", function(obj:FlxBasic) {
					obj.destroy();
				});

				set("center", function(obj:FlxObject) {
					obj.screenCenter();
				});

				set("setPos", function(obj:FlxObject, x:Float, y:Float) {
					obj.setPosition(x, y);
				});
			}
		} catch (e:Dynamic)
			trace('HScript ERRO: ' + e);
	}

	public function exists(func:String):Bool {
		if (!loaded) return false;
		return interp.variables.exists(func);
	}

	public function set(name:String, value:Dynamic):Void {
		if (!loaded) return;
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic {
		if (!loaded) return null;
		return interp.variables.get(name);
	}

	public function call(func:String, ?args:Array<Dynamic>):Dynamic {
		if (interp == null) return null;
		if (!interp.variables.exists(func))
			return null;

		try {
			var f = interp.variables.get(func);
			return Reflect.callMethod(null, f, args == null ? [] : args);
		}
		catch (e:Dynamic)
			trace('[HScript ERROR] Function: ' + func + ' -> ' + e);
		return null;
	}

	public function destroy():Void {
		interp = null;
		parser = null;
		loaded = false;
	}

	function resolvePath(name:String):Dynamic {
		var parts = name.split(".");
		var value:Dynamic = get(parts[0]);
		for (i in 1...parts.length) {
			if (value == null) return null;
			value = Reflect.field(value, parts[i]);
		}
		return value;
	}

	public function getString(name:String):String {
		var value = resolvePath(name);
		return (value != null) ? Std.string(value) : "";
	}

	public function getInt(name:String):Int {
		var value = resolvePath(name);
		return (value != null) ? Std.parseInt(Std.string(value)) : 0;
	}

	public function getFloat(name:String):Float {
		var value = resolvePath(name);
		return (value != null) ? Std.parseFloat(Std.string(value)) : 0;
	}

	public function getBool(name:String):Bool {
		var value = resolvePath(name);
		if (value == null) return false;

		if (Std.isOfType(value, Bool))
			return value;

		var str = Std.string(value).toLowerCase();
		return (str == "true" || str == "1");
	}

	public function getIntArray(name:String, ?limit:Int):Array<Int> {
		limit = (limit == null ? 2 : (limit < 1) ? 1 : limit);
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;

		if (arr == null) arr = [];
		var result:Array<Int> = [];

		for (i in 0...limit) {
			if (i < arr.length && arr[i] != null)
				result.push(Std.parseInt(Std.string(arr[i])));
			else
				result.push(0);
		}
		return result;
	}

	public function getFloatArray(name:String, ?limit:Int):Array<Float> {
		limit = (limit == null ? 2 : (limit < 1) ? 1 : limit);
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;

		if (arr == null) arr = [];
		var result:Array<Float> = [];

		for (i in 0...limit) {
			if (i < arr.length && arr[i] != null)
				result.push(Std.parseFloat(Std.string(arr[i])));
			else
				result.push(0);
		}
		return result;
	}

	public function getBoolArray(name:String, ?limit:Int):Array<Bool> {
		limit = (limit == null ? 2 : (limit < 1) ? 1 : limit);
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;

		if (arr == null) arr = [];
		var result:Array<Bool> = [];

		function toBool(v:Dynamic):Bool {
			if (v == null) return false;
			if (Std.isOfType(v, Bool)) return v;
			var str = Std.string(v).toLowerCase();
			return (str == "true" || str == "1");
		}

		for (i in 0...limit) {
			if (i < arr.length)
				result.push(toBool(arr[i]));
			else
				result.push(false);
		}
		return result;
	}
}