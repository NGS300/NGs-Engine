package objects;

import sys.FileSystem;
import openfl.utils.Assets;

typedef AnimData = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

typedef CharData = {
	var animations:Array<AnimData>;
	var image:String;
	var scale:Float;
	//var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	//var vocals_file:String;
}

class Character extends FlxSprite {
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animationsArray:Array<AnimData> = [];
    public var curCharacter:String;
	public var isPlayer = false;

	public function new(x:Float, y:Float, ?character:String, ?isPlayer:Bool) {
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		this.isPlayer = isPlayer ?? false;
        change(character ?? 'face');
    }

    public function change(char:String) {
		animationsArray = [];
		animOffsets = [];
		curCharacter = char;
		var file:String = 'characters/$char';

		if (!Paths.exists(Paths.getPath(file))) {
            
        }

        frames = Paths.atlas(file);

    }
}