package core;

import util.SaveUtil;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

@:structInit class SaveDataVars
{
	public var flashing = true;
	public var effects = true;
	public var antialiasing = true;
	public var distractions = true;
	public var downScroll = false;
}

@:structInit class SaveEngineVars
{
	public var autoPause = true;
	public var allowGPU = true;
	public var showFPS = true;
	public var showRAM = true;
	public var framerate = 60;
	public var discordRPC = true;
	public var userName = 'Guest';
	public var language = 'en-us';
}

class Settings
{
	public static var data:SaveDataVars = {};
	public static var game:SaveEngineVars = {};
	public static var pressed = SaveUtil.pressed;
	public static var justPressed = SaveUtil.justPressed;
	public static var justReleased = SaveUtil.justReleased;
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		'note_up' => [W, UP],
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_right' => [D, RIGHT],
		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_mute' => [ZERO],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN],
		'debug_2' => [EIGHT]
	];

	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up' => [DPAD_UP, Y],
		'note_left' => [DPAD_LEFT, X],
		'note_down' => [DPAD_DOWN, A],
		'note_right' => [DPAD_RIGHT, B],
		'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'accept' => [A, START],
		'back' => [B],
		'pause' => [START],
		'reset' => [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultPads:Map<String, Array<FlxGamepadInputID>> = null;

	public static function save()
	{
		SaveUtil.init(true, data, game, [keyBinds, gamepadBinds]);
		Log.info('Settings saved.');
	}

	public static function load()
	{
		defaultKeys = keyBinds.copy();
		defaultPads = gamepadBinds.copy();
		SaveUtil.init(false, data, game, [keyBinds, gamepadBinds]);
		Log.info('Setting loaded.');
	}
}
