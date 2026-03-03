package objects;

class BGGraphic extends FlxSprite {
    public function new(?x:Float, ?y:Float, width:Float, height:Float, ?color:FlxColor, ?scrollX:Float, ?scrollY:Float, ?unique:Bool) {
        super(x ?? 0, y ?? 0);
        makeGraphic(Std.int(width), Std.int(height), color, unique ?? false);
        antialiasing = Settings.data.antialiasing;
        scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
    }
}