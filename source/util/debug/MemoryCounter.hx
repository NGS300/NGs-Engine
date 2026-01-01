package util.debug;

/**
	The MemoryCounter class provides an easy-to-use monitor to display
	the current memory megabytes of an OpenFL project
 */
class MemoryCounter extends openfl.text.TextField {
	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	 */
	public var memoryMegas(get, never):Float;
	public static var memPeak = 0.0;

	public function new(y = 10.0) {
		super();
		this.x = 0;
		this.y = y;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat(Paths.font('inter/regular'), 10, 0xFFFFFF);
		autoSize = LEFT;
		multiline = true;
		text = "RAM: ";
	}

	override function __enterFrame(deltaTime:Float):Void { // Event Handlers
		var usedBytes:Float = memoryMegas;
		var usedMB:Float = usedBytes / (1024 * 1024);

		text = 'RAM: ' + formatMemory(usedBytes);
		if (usedMB > memPeak)
			memPeak = usedMB;

		if (Main.os.isDebug) {
			var reservedBytes:Float = cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED);
			text += ' / ' + formatMemory(reservedBytes) + ' (GC)';
			text += ' | Peak: ' + formatMemory(memPeak * 1024 * 1024);
		} else
			text += ' | Peak: ' + formatMemory(memPeak * 1024 * 1024);
		textColor = getMemoryColor(usedMB);
	}

	function getMemoryColor(usedMB:Float):Int {
		var min:Float;
		var max:Float;
		var c1:Int;
		var c2:Int;

		if (usedMB < 500) {
			min = 0;
			max = 500;
			c1 = 0xFF00FF00;
			c2 = 0xFF66FF66;
		} else if (usedMB < 1000) {
			min = 500;
			max = 1000;
			c1 = 0xFF66FF66;
			c2 = 0xFFFFFF00;
		} else if (usedMB < 1500) {
			min = 1000;
			max = 1500;
			c1 = 0xFFFFFF00;
			c2 = 0xFFFFE000;
		} else if (usedMB < 2000) {
			min = 1500;
			max = 2000;
			c1 = 0xFFFFE000;
			c2 = 0xFFFFA500;
		} else if (usedMB < 2500) {
			min = 2000;
			max = 2500;
			c1 = 0xFFFFA500;
			c2 = 0xFFFF7A00;
		} else if (usedMB < 3000) {
			min = 2500;
			max = 3000;
			c1 = 0xFFFF7A00;
			c2 = 0xFFFF0000;
		} else if (usedMB < 3500) {
			min = 3000;
			max = 3500;
			c1 = 0xFFFF0000;
			c2 = 0xFF8B00FF;
		} else {
			var blink = Math.sin(FlxG.game.ticks / 6);
			return blink > 0 ? 0xFF8B00FF : 0xFFFFFFFF;
		}

		var t = (usedMB - min) / (max - min);
		return lerpColor(c1, c2, t);
	}

	inline function lerp(a:Float, b:Float, t:Float):Float
		return a + (b - a) * t;

	inline function lerpColor(c1:Int, c2:Int, t:Float):Int {
		t = Math.max(0, Math.min(1, t));
		var r = Std.int(lerp((c1 >> 16) & 0xFF, (c2 >> 16) & 0xFF, t));
		var g = Std.int(lerp((c1 >> 8) & 0xFF, (c2 >> 8) & 0xFF, t));
		var b = Std.int(lerp(c1 & 0xFF, c2 & 0xFF, t));

		return (0xFF << 24) | (r << 16) | (g << 8) | b;
	}

	inline function formatFloat(value:Float, decimals:Int):String {
		var p = Math.pow(10, decimals);
		var v = Math.round(value * p) / p;
		var s = Std.string(v);
		var dot = s.indexOf(".");
		if (dot == -1)
			return s + "." + StringTools.lpad("", "0", decimals);

		var cur = s.length - dot - 1;
		if (cur < decimals)
			s += StringTools.lpad("", "0", decimals - cur);

		return s;
	}

	inline function formatMemory(bytes:Float):String {
		var mb = bytes / (1024 * 1024);
		if (mb >= 999.9)
			return formatFloat(mb / 1024, 2) + "GB";
		else
			return formatFloat(mb, 2) + "MB";
	}

	inline function getReservedMemory():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED);

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}