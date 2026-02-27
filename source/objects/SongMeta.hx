package objects;

class Info {
    public var stage:String;
	public var name:String;
	public var artist:String;
	public var charter:String;
	public var version:String;
    public var characters:Map<String, String>;

	public function new() {
        characters = new Map<String, String>();
    }
}


class Data {
	public var week:Int;
	public var song:String;
	public var character:String;
	public function new(?week:Int, ?name:String, ?character:String) {
		this.song = name ?? "";
		this.week = week ?? 0;
		this.character = character ?? "";
	}
}

class List {
	public var songs:Array<Data> = [];
	var autoWeek:Int = 0;

	public function new() {}

	public function add(name:Dynamic, ?characters:Dynamic, ?forceWeek:Int):Void {
		var songList:Array<String> =
			Std.isOfType(name, String) ? [cast name] : cast name;

		var charList:Array<String> =
			characters == null ? ['face'] :
			Std.isOfType(characters, String) ? [cast characters] :
			cast characters;

		var week:Int = forceWeek != null ? forceWeek : autoWeek;

		var charIndex:Int = 0;
		for (song in songList) {
            var character = charList[charIndex];
			songs.push(new Data(week, song, character));

			if (charList.length > 1)
				charIndex++;
		}
		if (forceWeek == null)
			autoWeek++;
	}
}

class Item extends FlxSpriteGroup {
    public var targetY:Int = 0;
    var firstFrame:Bool = true;
    var boxHeight:Float = 180;
    var boxWidth:Float = 500;

    public function new(data:Dynamic) {
        super();

        // Center X of the box relative to group
        var boxX:Float = -boxWidth / 2;
        var boxY:Float = -boxHeight / 2;

        // Main white cube background
        var bg = new FlxSprite(boxX, boxY);
        bg.makeGraphic(Std.int(boxWidth), Std.int(boxHeight), FlxColor.WHITE);
        add(bg);

        // Black square centered inside cube
        var blackSize:Int = 90;
        var iconBG = new FlxSprite(-blackSize / 2, -blackSize / 2);
        iconBG.makeGraphic(blackSize, blackSize, 0xAA000000);
        add(iconBG);

        // Icon centered inside black square
        var icon = new HealthIcon(data.character);
        icon.screenCenter(XY);
        icon.x = -icon.width / 2;
        icon.y = -icon.height / 2;
        add(icon);

        // Song name - top center of cube
        var songName = new FlxText(boxX, boxY + 10, boxWidth, data.song, 22);
        songName.setFormat(null, 22, FlxColor.BLACK, CENTER);
        add(songName);

        // Week - bottom left
        var weekText = new FlxText(boxX + 15, boxY + boxHeight - 30, 200, "Week " + data.week, 16);
        weekText.setFormat(null, 16, FlxColor.BLACK, LEFT);
        add(weekText);

        // Difficulty - bottom right
        var diffText = new FlxText(boxX, boxY + boxHeight - 30, boxWidth - 15, "????", 16);
        diffText.setFormat(null, 16, FlxColor.BLACK, RIGHT);
        add(diffText);
    }

    override public function update(elapsed:Float) {
        var targetPosY = getTargetPosY();
        x = FlxMath.lerp(x, FlxG.width * 0.5, 0.25);
        y = FlxMath.lerp(y, targetPosY, 0.25);
        super.update(elapsed);
    }

    function getTargetPosY():Float {
        var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.2);
        return (scaledY * 200) + (FlxG.height * 0.5);
    }

    public function snapToPosition():Void {
        x = FlxG.width * 0.5;
        y = getTargetPosY();
    }

    public function setAlpha(value:Float):Void {
        for (member in members) {
            if (member == null) continue;

            if (Std.isOfType(member, FlxSprite)) {
                var spr:FlxSprite = cast member;
                spr.alpha = value;
            }
        }
    }
}