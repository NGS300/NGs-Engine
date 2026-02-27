package util;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

class SaveUtil extends FlxSave {
	static var raw(get, null):Dynamic;
	inline static function get_raw():Dynamic
		return FlxG.save.data;

	@:access(FlxSave.validate)
	inline public static function savePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		return '${company}/${FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
	}

	public inline static function pressed(key:String, forceGamepad = false):Bool {
		if (key == null || key.length == 0)
			return false;
		var k = key.toUpperCase();

		// KEYBOARD
		if (!forceGamepad) {
			var flxKey = FlxKey.fromString(k);
			if (flxKey != FlxKey.NONE)
				return FlxG.keys.checkStatus(flxKey, PRESSED);
		} else if (FlxG.gamepads.lastActive != null) { // GAMEPAD
			var padKey = FlxGamepadInputID.fromString(k);
			if (padKey != FlxGamepadInputID.NONE)
				return FlxG.gamepads.anyPressed(padKey);
		}
		return false;
	}

	public inline static function justPressed(key:String, forceGamepad = false):Bool {
		if (key == null || key.length == 0)
			return false;
		var k = key.toUpperCase();

		// KEYBOARD
		if (!forceGamepad) {
			var flxKey = FlxKey.fromString(k);
			if (flxKey != FlxKey.NONE)
				return FlxG.keys.checkStatus(flxKey, JUST_PRESSED);
		} else if (FlxG.gamepads.lastActive != null) { // GAMEPAD
			var padKey = FlxGamepadInputID.fromString(k);
			if (padKey != FlxGamepadInputID.NONE)
				return FlxG.gamepads.anyJustPressed(padKey);
		}
		return false;
	}

	public inline static function justReleased(key:String, forceGamepad = false):Bool {
		if (key == null || key.length == 0)
			return false;
		var k = key.toUpperCase();

		// KEYBOARD
		if (!forceGamepad) {
			var flxKey = FlxKey.fromString(k);
			if (flxKey != FlxKey.NONE)
				return FlxG.keys.checkStatus(flxKey, JUST_RELEASED);
		} else if (FlxG.gamepads.lastActive != null) { // GAMEPAD
			var padKey = FlxGamepadInputID.fromString(k);
			if (padKey != FlxGamepadInputID.NONE)
				return FlxG.gamepads.anyJustReleased(padKey);
		}
		return false;
	}
    
	public static function init(save:Bool, data:SaveDataVars, engine:SaveEngineVars, binds:Array<Dynamic>) {
        var game = engine;
        if (save) {
            var save = new FlxSave();
            save.bind('controls_v1', savePath());
            save.data.keyboard = binds[0];
            save.data.gamepad = binds[1];
            save.flush();

			for (key in Reflect.fields(game)) {
				Reflect.setField(raw, key, Reflect.field(game, key));
				var save = new flixel.util.FlxSave();
				save.bind('engine_v1', savePath());
				Reflect.setField(save.data, key, Reflect.field(raw, key));
				save.flush();
            }

			for (key in Reflect.fields(data)) {
				Reflect.setField(raw, key, Reflect.field(data, key));
				var save = new flixel.util.FlxSave();
				save.bind('data_v1', savePath());
				Reflect.setField(save.data, key, Reflect.field(raw, key));
				save.flush();
			}
			FlxG.save.flush();
        } else {
			for (key in Reflect.fields(game)) {
				if (Reflect.hasField(raw, key))
					Reflect.setField(game, key, Reflect.field(raw, key));
            }

			for (key in Reflect.fields(data)) {
				if (Reflect.hasField(raw, key))
					Reflect.setField(data, key, Reflect.field(raw, key));
			}
			DiscordClient.check();

            if (!Main.os.isHtml5 && !Main.os.isSwitch) {
			    FlxG.autoPause = game.autoPause;

                if (raw.framerate == null) {
                    final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
					game.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
                }
			}

			if (game.framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = game.framerate;
				FlxG.drawFramerate = game.framerate;
			} else {
				FlxG.drawFramerate = game.framerate;
				FlxG.updateFramerate = game.framerate;
			}

			if (raw.volume != null)
				FlxG.sound.volume = raw.volume;
			if (raw.mute != null)
				FlxG.sound.muted = raw.mute;

			if (raw != null && raw.fullscreen)
				FlxG.fullscreen = raw.fullscreen;
        }
    }
}

class Scores {
	public static function setFreeplayScore(key:String, score:Int):Void {
		var slot = Highscore.freeplayScores;
		slot.set(key, score);

		var save = new FlxSave();
        save.bind('freeplayScores_v1', SaveUtil.savePath());
        save.data.freeplayScores = slot;
        save.flush();
	}

	public static function setWeekScore(key:String, score:Int):Void {
		var slot = Highscore.weekScores;
		slot.set(key, score);

		var save = new FlxSave();
        save.bind('weekScores_v1', SaveUtil.savePath());
        save.data.freeplayScores = slot;
        save.flush();
	}
}