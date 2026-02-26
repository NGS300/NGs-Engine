package objects;

import core.HScript;
import flixel.FlxBasic;
import openfl.utils.Assets as OpenFlAssets;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class Stage extends FlxBasic
{
	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

	public static var isPixel:Bool;

	public var camZoom:Float;
	public var curStage:String;

	public var cam_gf:Array<Float>;
	public var cam_dad:Array<Float>;
	public var cam_bf:Array<Float>;
	public var cam_speed:Float;

	var script:HScript;

	public function new(?daStage:String)
	{
		super();
		curStage = daStage ?? 'stage';
		// PlayState.curStage = curStage;
		create(curStage);
	}

	var names = new Map<String, Bool>();

	function addName(n:String)
	{
		if (!names.exists(n))
			names.set(n, true);
	}

	public function create(stage:String)
	{
		var song = PlayState.SONG;
		var stageName = switch (song.stage)
		{
			case 'halloween': 'spooky';
			default: curStage;
		}
		addName(stageName.toLowerCase());
		addName(stageName.toUpperCase());
		addName(stageName.substr(0, 1).toUpperCase() + stageName.substr(1).toLowerCase());

		for (name in names.keys())
		{
			var path = Paths.hxs('stage/$name');
			if (OpenFlAssets.exists(path))
			{
				script = new HScript(path);
				break;
			}
		}
		script.set("song", song);
		script.set("Stage", this);
		script.set("stage", {name: curStage, pixel: false});
		script.set("cam", {speed: 1, zoom: 0.9});

		script.set("gf", {position: [400, 130], camPos: [0, 0]});
		script.set("dad", {position: [100, 100], camPos: [0, 0]});
		script.set("bf", {position: [770, 100], camPos: [0, 0]});

		var gfVersion = switch (song.gfVersion)
		{
			case 'gf-car': 'gf-car';
			case 'gf-christmas': 'gf-christmas';
			case 'gf-pixel': 'gf-pixel';
			default: 'gf';
		}
		gf = characterPos("gf", gfVersion);
		script.set("GF", gf);

		dad = characterPos("dad", song.player2);
		script.set("DAD", dad);

		bf = characterPos("bf", song.player1);
		script.set("BF", bf);

		script.call("onCreate");

		cam_gf = script.getFloatArray("gf.camPos");
		cam_dad = script.getFloatArray("dad.camPos");
		cam_bf = script.getFloatArray("bf.camPos");
		cam_speed = script.getFloat('cam.speed');
		isPixel = script.getBool('stage.pixel');
		camZoom = script.getFloat('cam.zoom');
	}

	function characterPos(charName:String, version:String):Character
	{
		var pos = script.getFloatArray(charName + ".position");
		var char = new Character(pos[0], pos[1], version);

		if (char.curCharacter.startsWith("gf"))
		{
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}

		char.x += char.positionArray[0];
		char.y += char.positionArray[1];

		return char;
	}

	public function createPost()
	{
		script.call("onCreatePost");
	}

	public function addBehind(of:String)
	{
		script.call("onAddBehind", [of]);
	}

	public function updates(elapsed:Float)
	{
		script.call("onUpdate", [elapsed]);
	}

	public function stepHit(curStep:Int)
	{
		script.set("curStep", curStep);
		script.call("onStep", [curStep]);
	}

	public function beatHit(curBeat:Int)
	{
		script.set("curBeat", curBeat);
		script.call("onBeat", [curBeat]);
	}

	public function countdownTick(count:Countdown, num:Int)
	{
	}

	public function startSong()
	{
	}
}
