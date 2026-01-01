package util.debug;

/**
	The FPSCounter class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
 */
class FPSCounter extends openfl.text.TextField {
	@:noCompletion private var times:Array<Float>;
	public var displayFPS(default, null):Int; // FPS for Users
	public var realFPS(default, null):Int; // Real FPS Engine (Debug)
	public var minFPS = 9999; // FPS Last Peak
	var blinkTimer = 0.0;

	public function new(y = 10.0) {
		super();
		this.x = 0;
		this.y = y;
		realFPS = 0;
		displayFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat(Paths.font('inter/regular'), 10, 0xFFFFFF);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";
		times = [];
	}

	var deltaTimeout = 0.0;
	override function __enterFrame(deltaTime:Float):Void { // Event Handlers
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < 50) {
			deltaTimeout += deltaTime;
			return;
		}

		realFPS = times.length; // Debug FPS
		displayFPS = realFPS > FlxG.drawFramerate ? FlxG.drawFramerate : realFPS; // User's FPS

		if (displayFPS < minFPS)
			minFPS = displayFPS;

		if (Main.os.isDebug)
			text = 'FPS: ${displayFPS} (${realFPS}) | Min: ${minFPS}';
		else
			text = 'FPS: ${displayFPS}';
		textColor = getFPSColor(displayFPS, FlxG.drawFramerate, deltaTime);
		deltaTimeout = 0.0;
	}

	function getFPSColor(displayFPS:Int, capFPS:Int, delta:Float):Int {
		var ratio:Float = displayFPS / capFPS;

		blinkTimer += delta * 0.01;
		if (blinkTimer > 1)
			blinkTimer = 0;

		if (ratio < 0.25)
			return blinkTimer > 0.5 ? 0xFFFF0000 : 0xFFFFFFFF;

		if (ratio < 0.5)
			return lerpColor(0xFFFF0000, 0xFFFFA500, ratio / 0.5); // Red → Orange
		else if (ratio < 0.75)
			return lerpColor(0xFFFFA500, 0xFFFFFF00, (ratio - 0.5) / 0.25); // Orange → Yellow
		else
			return lerpColor(0xFFFFFF00, 0xFF00FF00, (ratio - 0.75) / 0.25); // Yellow → Green
	}

	inline function lerpColor(a:Int, b:Int, t:Float):Int {
		t = t < 0 ? 0 : (t > 1 ? 1 : t);

		var ar = (a >> 16) & 0xFF;
		var ag = (a >> 8) & 0xFF;
		var ab = a & 0xFF;

		var br = (b >> 16) & 0xFF;
		var bg = (b >> 8) & 0xFF;
		var bb = b & 0xFF;

		var r = Std.int(ar + (br - ar) * t);
		var g = Std.int(ag + (bg - ag) * t);
		var b2 = Std.int(ab + (bb - ab) * t);

		return 0xFF000000 | (r << 16) | (g << 8) | b2;
	}
}