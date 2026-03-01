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
    public var color:Int;

	public function new(?week:Int, ?name:String, ?character:String, ?color:Int) {
		this.song = name ?? "";
		this.week = week ?? 0;
		this.character = character ?? "face";
        this.color = color ?? FlxColor.fromRGB(17, 17, 17);
	}
}

class List {
	public var songs:Array<Data> = [];
	var autoWeek:Int = 0;

	public function new() {}

    public function add(name:Dynamic, ?characters:Dynamic, ?colors:Dynamic, ?forceWeek:Int):Void {
        var songList:Array<String> =
            Std.isOfType(name, String) ? [cast name] : cast name;

        var charList:Array<String>;
        if (characters == null)
            charList = ["face"];
        else if (Std.isOfType(characters, String))
            charList = [cast characters];
        else
            charList = cast characters;

        if (charList == null || charList.length == 0)
            charList = ["face"];


        var colorList:Array<FlxColor> = [];
        if (colors == null)
            colorList = [FlxColor.fromRGB(17, 17, 17)];
        else {
            var raw:Array<Dynamic> = cast colors;

            if (raw.length == 3 && !Std.isOfType(raw[0], Array)) { // only 1 [r,g,b]
                colorList = [
                    FlxColor.fromRGB(raw[0], raw[1], raw[2])
                ];
            } else {
                for (c in raw) { // more 1 [[r,g,b], [r,g,b]]
                    var rgb:Array<Dynamic> = cast c;
                    colorList.push(
                        FlxColor.fromRGB(rgb[0], rgb[1], rgb[2])
                    );
                }
            }
        }

        var week:Int = forceWeek != null ? forceWeek : autoWeek;
        for (i in 0...songList.length) {
            var charIndex = i < charList.length ? i : charList.length - 1;
            var colorIndex = i < colorList.length ? i : colorList.length - 1;

            songs.push(new Data(
                week,
                songList[i],
                charList[charIndex],
                colorList[colorIndex]
            ));
        }

        if (forceWeek == null)
            autoWeek++;
    }
}

class Item extends FlxSpriteGroup {
    public var diffText:HUDText;
    public var targetY:Int = 0;
    var firstFrame:Bool = true;
    var boxHeight:Float = 180;
    var boxWidth:Float = 500;

    public function new(data:Dynamic) {
        super();

        var boxX:Float = -boxWidth / 2;
        var boxY:Float = -boxHeight / 2;
        
        var bg = new BGGraphic(boxX, boxY, boxWidth, boxHeight);
        add(bg);

        var blackSize:Int = 90;
        var blackPos:Float = -blackSize / 2;
        var iconBG = new BGGraphic(blackPos, blackPos, blackSize, blackSize, 0xAA000000);
        add(iconBG);

        var icon = new HealthIcon(data.character);
        icon.screenCenter();
        icon.x = -icon.width / 2;
        icon.y = -icon.height / 2;
        add(icon);

        var color = FlxColor.BLACK;
        var songName = new HUDText(boxX, boxY + 6, 'montserrat/bold', data.song, 24, boxWidth);
        songName.minusSize = 4;
        songName.format('center', color);
        add(songName);

        var textY = boxY + boxHeight - 26;
        var textFont = 'nexa/heavy';
        diffText = new HUDText(boxX + 6, textY, textFont, "", 18, 200);
        diffText.minusSize = 2;
        diffText.format('left', color);
        add(diffText);

        var bpmText = new HUDText(boxX, textY, textFont, "BPM 0", 18, boxWidth);
        bpmText.minusSize = 2;
        bpmText.format('center', color);
        add(bpmText);

        var weekText = new HUDText(boxX, textY, textFont, "WEEK " + data.week, 18, boxWidth - 15);
        weekText.minusSize = 2;
        weekText.format('right', color);
        add(weekText);
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