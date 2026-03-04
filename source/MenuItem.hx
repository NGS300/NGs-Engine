package;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	var isFlashing:Bool = false;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths.image('menus/storymode/weeks/' + weekNum));
		add(week);
	}

	public function startFlashing():Void
		isFlashing = true;

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var targetPosY = (targetY * 120) + 480;
		var targetPosX = (-targetY * 40) + 200; // 40 controla diagonal

		y = FlxMath.lerp(y, targetPosY, 0.17 * (60 / FlxG.save.data.fpsCap));
		x = FlxMath.lerp(x, targetPosX, 0.17 * (60 / FlxG.save.data.fpsCap));

		// week.scale.x = week.scale.y = 1 - Math.abs(targetY) * 0.05;
		var scaleShit:Float = 1 - Math.abs(targetY) * 0.15;
		// week.scale.set(scaleShit, scaleShit);

		week.scale.x = FlxMath.lerp(week.scale.x, scaleShit, 0.095);
		week.scale.y = FlxMath.lerp(week.scale.y, scaleShit, 0.095);
		alpha = 1 - Math.abs(targetY) * 0.4;

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33FFFF;
		else if (FlxG.save.data.flashing)
			week.color = FlxColor.WHITE;
	}
}
