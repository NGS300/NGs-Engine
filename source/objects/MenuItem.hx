package objects;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	var isFlashing:Bool = false;

	public var angleX:Float = 120;
	public var angleY:Float = 40;
	public var startX:Float = 0;
	public var startY:Float = 0;
	public var scaleMultiplier:Float = 0.15;
	public var alphaMultiplier:Float = 0.4;
	public var disabled:Bool = false;

	public function new(x:Float, y:Float, weekNum:Int = 0, ?path:String = "menus/storymode/weeks/", ?preloadGraphic = true)
	{
		super(x, y);
		startX = x;
		startY = y;
		week = new FlxSprite();
		if (preloadGraphic)
			week.loadGraphic(Paths.image(path + weekNum));
		add(week);
	}

	public inline function loadSprite(path:String)
		week.loadGraphic(Paths.image(path));

	public inline function startFlashing():Void
		isFlashing = true;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var targetPosY = (targetY * angleX) + startX;
		var targetPosX = (-targetY * angleY) + startY; // 40 controla diagonal

		y = FlxMath.lerp(y, targetPosY, 0.17 * (60 / FlxG.save.data.fpsCap));
		x = FlxMath.lerp(x, targetPosX, 0.17 * (60 / FlxG.save.data.fpsCap));

		// week.scale.x = week.scale.y = 1 - Math.abs(targetY) * 0.05;
		var scaleShit:Float = 1 - Math.abs(targetY) * scaleMultiplier;
		// week.scale.set(scaleShit, scaleShit);

		week.scale.x = FlxMath.lerp(week.scale.x, scaleShit, 0.095);
		week.scale.y = FlxMath.lerp(week.scale.y, scaleShit, 0.095);
		alpha = 1 - Math.abs(targetY) * alphaMultiplier;

		if (isFlashing)
			flashingInt += 1;

		if (disabled)
			week.color = 0xFF646464;
		else
			week.color = FlxColor.WHITE;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33FFFF;
		else if (FlxG.save.data.flashing)
			week.color = FlxColor.WHITE;
	}
}
