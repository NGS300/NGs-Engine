package objects.internal;

import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class SoundTray extends flixel.system.ui.FlxSoundTray {
	static inline var FIXED_DT:Float = 1 / 60;
	var barTimeAcc:Float = 0;

	var barColors:Array<FlxColor> = [];
	var muteIndicator:Bitmap;
	var maxIndicator:Bitmap;

	public function new() {
		super();
		removeChildren();
		var width = 80;
		visible = false;
		active = false;

		var bg = new Bitmap(new BitmapData(width, 30, true, 0x7F000000));
		addChild(bg);
		screenCenter();

		var text = new openfl.text.TextField();
		text.width = bg.width;
		text.height = bg.height;
		text.selectable = false;
		var tf = new openfl.text.TextFormat(Paths.font('luckiest_guy'), 10, 0xFFFFFF);
		tf.align = openfl.text.TextFormatAlign.CENTER;
		text.defaultTextFormat = tf;
		text.text = "VOLUME";
		text.y = 16;
		addChild(text);

		_bars = [];
		barColors = [];

		var bx = 10;
		var by = 14;

		for (i in 0...10) {
			var bmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			bmp.x = bx;
			bmp.y = by;
			bmp.alpha = 0;
			bmp.visible = false;

			addChild(bmp);
			_bars.push(bmp);
			barColors.push(FlxColor.WHITE);

			bx += 6;
			by--;
		}

		maxIndicator = new Bitmap(new BitmapData(3, 14, true, FlxColor.RED));
		var lastBar = _bars[_bars.length - 1];
		maxIndicator.x = lastBar.x + 6;
		maxIndicator.y = lastBar.y - (maxIndicator.height - lastBar.height);
		maxIndicator.alpha = 0;
		maxIndicator.visible = false;
		addChild(maxIndicator);

		muteIndicator = new Bitmap(new BitmapData(16, 12, true, 0x00000000));
		var bd = muteIndicator.bitmapData;
		bd.fillRect(new Rectangle(0, 4, 6, 4), FlxColor.WHITE);
		bd.fillRect(new Rectangle(6, 3, 4, 6), FlxColor.WHITE);
		for (i in 0...12)
			bd.setPixel32(10 + i % 4, i, FlxColor.RED);

		muteIndicator.x = (width - muteIndicator.width) / 2;
		muteIndicator.y = text.y - 13;
		muteIndicator.alpha = 0;
		muteIndicator.visible = false;
		addChild(muteIndicator);

		y = -height;
	}

	override public function show(up = false):Void {
		var v = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		var clamped = (up && v >= 1) || (!up && v <= 0);

		if (!silent && !clamped) {
			var sound:String = up ? volumeUpSound : volumeDownSound;
			if (sound != null)
				FlxG.sound.load(sound).play().volume = 0.3;
		}

		_timer = 1;
		visible = true;
		active = true;
	}

	override public function update(MS:Float):Void {
		var dt = MS / 1000;
		var showing = _timer > 0;

		var targetY = showing ? 0 : -height;
		y += (targetY - y) * Math.min(1, dt * 8);

		var targetAlpha = showing ? 1.0 : 0.0;
		alpha += (targetAlpha - alpha) * Math.min(1, dt * 8);

		if (_timer > 0) {
			_timer -= dt;
		} else if (y <= -height + 0.5 && alpha <= 0.01) {
			visible = false;
			active = false;
			if (FlxG.save.isBound) {
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
		}

		barTimeAcc += dt;
		if (barTimeAcc > 0.25)
			barTimeAcc = 0.25;

		while (barTimeAcc >= FIXED_DT) {
			updateBars(FIXED_DT);
			barTimeAcc -= FIXED_DT;
		}
	}

	function updateBars(dt:Float):Void {
		var realVolume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		if (realVolume < 0.0001)
			realVolume = 0;

		for (i in 0..._bars.length) {
			var bar = _bars[i];
			var active = realVolume >= (i + 1) * 0.1;

			bar.visible = active;
			bar.alpha = active ? 1 : 0;

			if (active) {
				var color = getColor(realVolume);
				if (barColors[i] != color) {
					barColors[i] = color;
					bar.bitmapData.fillRect(bar.bitmapData.rect, color);
				}
			}
		}

		var last = _bars[_bars.length - 1];
		var showMax = !FlxG.sound.muted && last.visible;
		maxIndicator.visible = showMax;
		maxIndicator.alpha = showMax ? 1 : 0;

		var muteTarget = (FlxG.sound.muted || realVolume <= 0.001) ? 1.0 : 0.0;
		muteIndicator.alpha += (muteTarget - muteIndicator.alpha) * Math.min(1, dt * 8);
		muteIndicator.visible = muteIndicator.alpha > 0.01;
	}

	inline function getColor(v:Float):FlxColor {
		v = Math.max(0, Math.min(1, v));
		if (v <= 0.2)
			return FlxColor.interpolate(0xFF0B5F1E, FlxColor.GREEN, v / 0.2);
		if (v <= 0.4)
			return FlxColor.interpolate(FlxColor.GREEN, FlxColor.YELLOW, (v - 0.2) / 0.2);
		if (v <= 0.6)
			return FlxColor.YELLOW;
		if (v <= 0.8)
			return FlxColor.interpolate(FlxColor.YELLOW, FlxColor.ORANGE, (v - 0.6) / 0.2);

		return FlxColor.interpolate(FlxColor.ORANGE, FlxColor.RED, (v - 0.8) / 0.2);
	}
}