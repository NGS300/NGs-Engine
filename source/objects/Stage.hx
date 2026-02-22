package objects;

import core.HScript;
import flixel.FlxBasic;

enum Countdown {
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class Stage extends FlxBasic {
    public var dad:Character;
	public var gf:Character;
    public var bf:Boyfriend;

    public var curStage:String;
    public var isPixel = false;
    public var camZoom = 0.9;

	var script:HScript;
    public function new(?daStage:String) {
        super();
		curStage = daStage ?? 'stage';
        PlayState.curStage = curStage;
		create();
	}

    public function create() {
        var stageName = switch (curStage) {
            case 'halloween': 'Spooky';
            default: curStage;
        }
        script = new HScript(Paths.getPath('$stageName.hxs', 'shared/stage'));
        var song = PlayState.SONG;

        script.set("FlxSprite", flixel.FlxSprite);
        script.set('FlxG', flixel.FlxG);
        script.set("Sprite", BGSprite);
        script.set("Std", Std);
        script.set("Paths", Paths);

        script.set("add", function(obj:FlxBasic) {
            return FlxG.state.add(obj);
        });

        script.set("remove", function(obj:FlxBasic) {
            return FlxG.state.remove(obj);
        });

        script.set("stage", this);
        script.set("curStage", curStage);
        script.set("camZoom", camZoom);
        script.set("song", song);

        //gf = new Character(0, 0, 'gf');
        //gf.scrollFactor.set(0.95, 0.95);

        //dad = new Character(0, 0, song.player2);
        //bf = new Boyfriend(0, 0, song.player1);

        script.set("gf", gf);
        script.set("dad", dad);
        script.set("bf", bf);

        script.call("onCreate");
    }

    public function createPost() {
        script.call("onCreatePost");
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