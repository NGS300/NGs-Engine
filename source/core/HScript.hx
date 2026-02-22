package core;

import hscript.Parser;
import hscript.Interp;
import sys.FileSystem;
import sys.io.File;

class HScript {
	public var interp(default, null):Interp;
	public var path(default, null):String;
	var loaded = false;
	var parser:Parser;

	public function new(scriptPath:String) {
		path = scriptPath;
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
		} catch (e:Dynamic)
			trace('HScript ERRO: ' + e);
	}

	public function reload():Void {
		loaded = false;
		load();
	}

	public function exists(func:String):Bool {
		if (!loaded)
			return false;
		return interp.variables.exists(func);
	}

	public function set(name:String, value:Dynamic):Void {
		if (!loaded)
			return;
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic {
		if (!loaded)
			return null;
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
}