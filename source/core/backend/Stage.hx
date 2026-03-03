package core.backend;

import objects.Character;

enum Countdown {
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class Stage extends flixel.FlxBasic {
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
    public function new(?daStage:String) {
        super();
		curStage = daStage ?? 'stage';
		create(curStage);
	}

    public function create(stage:String) {
        var song = PlayState.SONG;
        script = new HScript('stage/$stage');
        script.set("song", song);
        script.set("Stage", this);
        script.set("stage", { name: curStage, pixel: false });
        script.set("cam", { speed: 1, zoom: 0.9 });

        script.set("gf", { pos: [0, 0], cam: [0, 0] });
        script.set("dad", { pos: [0, 0], cam: [0, 0] });
        script.set("bf", { pos: [0, 0], cam: [0, 0] });
        script.call("onCreate");

        gf = characterPos("gf");
        script.set("GF", gf);

        dad = characterPos("dad");
        script.set("DAD", dad);
        
        bf = characterPos("bf");
        script.set("BF", bf);
        script.call("onCreate");

        cam_gf  = script.getFloatArray("gf.cam");
        cam_dad = script.getFloatArray("dad.cam");
        cam_bf  = script.getFloatArray("bf.cam");
        cam_speed = script.getFloat('cam.speed');
        isPixel = script.getBool('stage.pixel');
        camZoom = script.getFloat('cam.zoom');
    }

    public function createPost() {
        script.call("onCreatePost");
    }

    function characterPos(name:String):Character {
        var song = PlayState.song;
        var pos = song.positions.get(name);
        var char = new Character(pos[0], pos[1], song.characters.get(name));

        if (char.curCharacter.startsWith("gf")) {
            char.scrollFactor.set(0.95, 0.95);
            char.danceEveryNumBeats = 2;
        }

        char.x += char.positionArray[0];
        char.y += char.positionArray[1];

        var mapPos = script.getFloatArray('$name.pos');
        char.x += (mapPos != null && mapPos.length > 0) ? mapPos[0] : 0;
        char.y += (mapPos != null && mapPos.length > 1) ? mapPos[1] : 0;
        
        return char;
    }

    public function addBehind(of:String) {
        script.call("onAddBehind", [of]);
    }

    override function update(elapsed:Float) {
        script.call("onUpdate", [elapsed]);
    }

    public function stepHit(curStep:Int) {
        script.set("curStep", curStep);
        script.call("onStep", [curStep]);
    }

    public function beatHit(curBeat:Int) {
        script.set("curBeat", curBeat);
        script.call("onBeat", [curBeat]);
    }

    public function countdownTick(count:Countdown, num:Int) {}
	public function startSong() {}
}