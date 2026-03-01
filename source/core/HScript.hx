package core;

import hscript.Parser;
import hscript.Interp;
import flixel.FlxBasic;
import flixel.FlxObject;
import openfl.display.BlendMode;

class HScript
{
	public var interp(default, null):Interp;
	public var path(default, null):String;
	public var canObjects:Bool = true;

	var loaded:Bool = false;
	var parser:Parser;

	public function new(name:String, ?folder:String, ?isScript:Bool)
	{
		path = Paths.hxs(name, folder, isScript).toLowerCase();
		load();
	}

	public function reload():Void
	{
		loaded = false;
		load();
	}

	public function load():Void
	{
		if (!sys.FileSystem.exists(path))
		{
			trace("[HScript ERROR]");
			trace("File not found: " + path);
			return;
		}

		parser = new Parser();
		interp = new Interp();
		try
		{
			var content = sys.io.File.getContent(path);
			var program = parser.parseString(content);
			interp.execute(program);
			loaded = true;
			set("instance", this);
			set('trace', haxe.Log.trace);

			set("Paths", Paths);
			set("Settings", Settings);

			set("FlxG", FlxG);
			set("Std", Std);
			set("Math", Math);
			set("Type", Type);
			set("Reflect", Reflect);
			set("StringTools", StringTools);

			set("Conductor", Conductor);

			set("randomInt", function(min:Int, max:Int)
			{
				return FlxG.random.int(min, max);
			});

			set("randomFloat", function(min:Float, max:Float)
			{
				return FlxG.random.float(min, max);
			});

			set("randomBool", function(change:Float)
			{
				return FlxG.random.bool(change);
			});

			set("FlxTween", FlxTween);
			set("FlxTweenType", {
				PINGPONG: cast PINGPONG,
				LOOPING: cast LOOPING,
				ONESHOT: cast ONESHOT,
				BACKWARD: cast BACKWARD
			});
			set("PINGPONG", cast PINGPONG);
			set("LOOPING", cast LOOPING);
			set("ONESHOT", cast ONESHOT);
			set("BACKWARD", cast BACKWARD);
			set("PERSIST", cast PERSIST);

			set("FlxEase", FlxEase);
			set("Ease", {
				Linear: FlxEase.linear,
				QuadIn: FlxEase.quadIn,
				QuadOut: FlxEase.quadOut,
				QuartOut: FlxEase.quartOut,
				BounceOut: FlxEase.bounceOut
			});

			set("Linear", FlxEase.linear);
			set("QuadIn", FlxEase.quadIn);
			set("QuadOut", FlxEase.quadOut);
			set("QuartOut", FlxEase.quartOut);
			set("QuartInOut", FlxEase.quartInOut);
			set("BounceOut", FlxEase.bounceOut);

			set("FlxTimer", FlxTimer);
			if (canObjects)
			{
				set("Character", Character);
				set('HUDText', HUDText);
				set("BGAnim", BGAnim);
				set("BGSprite", BGSprite);
				set('BGGraphic', BGGraphic);
				set("FlxGroup", FlxGroup);
				set("FlxSprite", FlxSprite);
				set("BlendMode", {
					NORMAL: cast BlendMode.NORMAL,
					ADD: cast BlendMode.ADD,
					MULTIPLY: cast BlendMode.MULTIPLY,
					SCREEN: cast BlendMode.SCREEN,
					SUBTRACT: cast BlendMode.SUBTRACT
				});

				set('FlxSound', FlxSound);

				set("add", function(obj:FlxBasic)
				{
					return FlxG.state.add(obj);
				});

				set("remove", function(obj:FlxBasic)
				{
					return FlxG.state.remove(obj);
				});

				set("tween", function(obj:Dynamic, values:Dynamic, ?duration:Float, ?ease)
				{
					return FlxTween.tween(obj, values, duration, {ease: ease});
				});

				set("angle", function(obj:Dynamic, fromAngle:Float, toAngle:Float, ?duration:Float, ?ease)
				{
					return FlxTween.angle(obj, fromAngle, toAngle, duration, {ease: ease});
				});

				set("destroy", function(obj:FlxBasic)
				{
					obj.destroy();
				});

				set("center", function(obj:FlxObject)
				{
					obj.screenCenter();
				});

				set("setPos", function(obj:FlxObject, x:Float, y:Float)
				{
					obj.setPosition(x, y);
				});
			}
		}
		catch (e:hscript.Expr.Error)
		{ // Parse-time error (syntax errors)
			trace("[HScript PARSE ERROR]");
			trace("File: " + path);
			trace("Line: " + e.line);
			trace("Message: " + e.e);
			trace("Origin: " + e.origin);
			return;
		}
		catch (e:Dynamic)
		{ // Runtime error during script execution
			trace("[HScript EXECUTION ERROR]");
			trace("File: " + path);
			trace(e);
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack())); // Optional: print stack trace
			return;
		}
	}

	public function exists(func:String):Bool
	{
		if (!loaded)
			return false;
		return interp.variables.exists(func);
	}

	public function set(name:String, value:Dynamic):Void
	{
		if (!loaded)
			return;
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic
	{
		if (!loaded)
			return null;
		return interp.variables.get(name);
	}

	public function call(func:String, ?args:Array<Dynamic>):Dynamic
	{
		if (interp == null)
			return null;
		if (!interp.variables.exists(func))
			return null;

		try
		{
			var f = interp.variables.get(func);
			return Reflect.callMethod(null, f, args == null ? [] : args);
		}
		catch (e:hscript.Expr.Error)
		{ // Runtime error inside script function
			trace("[HScript INSIDE RUNTIME ERROR]");
			trace("File: " + path);
			trace("Function: " + func);
			trace("Line: " + e.line);
			trace("Message: " + e.e);
		}
		catch (e:Dynamic)
		{ // Generic runtime error
			trace("[HScript RUNTIME ERROR]");
			trace("File: " + path);
			trace("Function: " + func);
			trace(e);
			trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack())); // Optional: print stack trace
		}

		return null;
	}

	public function destroy():Void
	{
		interp = null;
		parser = null;
		loaded = false;
	}

	function resolvePath(name:String):Dynamic
	{
		var parts = name.split(".");
		var value:Dynamic = get(parts[0]);
		for (i in 1...parts.length)
		{
			if (value == null)
				return null;
			value = Reflect.field(value, parts[i]);
		}
		return value;
	}

	public function getString(name:String):String
	{
		var value = resolvePath(name);
		return (value != null) ? Std.string(value) : "";
	}

	public function getInt(name:String):Int
	{
		var value = resolvePath(name);
		return (value != null) ? Std.parseInt(Std.string(value)) : 0;
	}

	public function getFloat(name:String):Float
	{
		var value = resolvePath(name);
		return (value != null) ? Std.parseFloat(Std.string(value)) : 0;
	}

	public function getBool(name:String):Bool
	{
		var value = resolvePath(name);
		if (value == null)
			return false;

		if (Std.isOfType(value, Bool))
			return value;

		var str = Std.string(value).toLowerCase();
		return (str == "true" || str == "1");
	}

	public function getStringArray(name:String, ?limit:Int):Array<String>
	{
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;
		if (arr == null)
			arr = [];

		var max:Int;
		if (limit == null)
			max = 2;
		else if (limit < 0)
			max = arr.length;
		else if (limit < 1)
			max = 1;
		else
			max = limit;

		var result:Array<String> = [];
		for (i in 0...max)
		{
			if (i < arr.length && arr[i] != null)
				result.push(Std.string(arr[i]));
			else
				result.push("");
		}
		return result;
	}

	public function getIntArray(name:String, ?limit:Int):Array<Int>
	{
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;
		if (arr == null)
			arr = [];

		var max:Int;
		if (limit == null)
			max = 2;
		else if (limit < 0)
			max = arr.length;
		else if (limit < 1)
			max = 1;
		else
			max = limit;

		var result:Array<Int> = [];
		for (i in 0...max)
		{
			if (i < arr.length && arr[i] != null)
				result.push(Std.parseInt(Std.string(arr[i])));
			else
				result.push(0);
		}
		return result;
	}

	public function getFloatArray(name:String, ?limit:Int):Array<Float>
	{
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;
		if (arr == null)
			arr = [];

		var max:Int;
		if (limit == null)
			max = 2;
		else if (limit < 0)
			max = arr.length;
		else if (limit < 1)
			max = 1;
		else
			max = limit;

		var result:Array<Float> = [];
		for (i in 0...max)
		{
			if (i < arr.length && arr[i] != null)
				result.push(Std.parseFloat(Std.string(arr[i])));
			else
				result.push(0);
		}
		return result;
	}

	public function getBoolArray(name:String, ?limit:Int):Array<Bool>
	{
		var target:Dynamic = resolvePath(name);
		var arr:Array<Dynamic> = cast target;
		if (arr == null)
			arr = [];

		var max:Int;
		if (limit == null)
			max = 2;
		else if (limit < 0)
			max = arr.length;
		else if (limit < 1)
			max = 1;
		else
			max = limit;

		var result:Array<Bool> = [];
		function toBool(v:Dynamic):Bool
		{
			if (v == null)
				return false;
			if (Std.isOfType(v, Bool))
				return v;
			var str = Std.string(v).toLowerCase();
			return (str == "true" || str == "1");
		}

		for (i in 0...max)
		{
			if (i < arr.length)
				result.push(toBool(arr[i]));
			else
				result.push(false);
		}
		return result;
	}
}
