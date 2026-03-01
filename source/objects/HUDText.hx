package objects;

class HUDText extends FlxText {
    public var folder:Null<String>;
    public var minusSize:Int = 0;
    var embeddedFont:Bool;
    var pathFormat:String;
    var sizeFormat:Int;

    public function new(?x:Float, ?y:Float, path:String, ?text:String, ?size:Int, ?fieldWidth:Float, ?embedded:Bool) {
        var sizer = size ?? 8;
        super(x ?? 0, y ?? 0, fieldWidth ?? 0, text ?? '', sizer, embedded ?? true);
        antialiasing = Settings.data.antialiasing;
        sizeFormat = sizer;
        pathFormat = path;
    }

    public function format(?alignment:String, ?color:FlxColor, ?borderStyle:String, ?borderColor:FlxColor) {
        var alignStr = (alignment ?? "LEFT").toUpperCase();
        var borderStr = (borderStyle ?? "NONE").toUpperCase();

        var alignValue:FlxTextAlign = switch (alignStr) {
            case "CENTER": FlxTextAlign.CENTER;
            case "RIGHT": FlxTextAlign.RIGHT;
            case "JUSTIFY": FlxTextAlign.JUSTIFY;
            default: FlxTextAlign.LEFT;
        };

        var borderValue:FlxTextBorderStyle = switch (borderStr) {
            case "OUTLINE": FlxTextBorderStyle.OUTLINE;
            case "SHADOW": FlxTextBorderStyle.SHADOW;
            case "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST;
            default: FlxTextBorderStyle.NONE;
        };

        setFormat(
            Paths.font(pathFormat, folder ?? null),
            sizeFormat - minusSize,
            color,
            alignValue,
            borderValue,
            borderColor,
            embeddedFont
        );
    }
}